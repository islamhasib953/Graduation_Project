const User = require("../models/user.model");
const Child = require("../models/child.model");
const Doctor = require("../models/doctor.model");
const Appointment = require("../models/appointment.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const userRoles = require("../utils/userRoles");
const bcrypt = require("bcryptjs");
const generateJWT = require("../utils/genrate.JWT");
const {
  sendNotificationCore,
} = require("../controllers/notifications.controller");
const mongoose = require("mongoose");
const { deleteObject } = require("../utils/s3-operations");
const getAllUsers = asyncWrapper(async (req, res) => {
  const query = req.query;
  const limit = query.limit || 10;
  const page = query.page || 1;
  const skip = (page - 1) * limit;

  const users = await User.find({}, { __v: false, password: false })
    .limit(limit)
    .skip(skip);
  res.json({ status: httpStatusText.SUCCESS, data: { users } });
});


const register = asyncWrapper(async (req, res, next) => {
  console.log("register started - req.body:", req.body);
  const {
    firstName,
    lastName,
    gender,
    phone,
    address,
    email,
    password,
    role,
    specialise,
    about,
    rate,
    availableDays,
    availableTimes,
  } = req.body;
  console.log("Extracted fields:", {
    firstName,
    lastName,
    gender,
    phone,
    address,
    email,
    password,
    role,
    specialise,
    about,
    rate,
    availableDays,
    availableTimes,
  });

  const oldUser = await User.findOne({ email });
  console.log("Check for existing user - oldUser:", oldUser);
  const oldDoctor = await Doctor.findOne({ email });
  console.log("Check for existing doctor - oldDoctor:", oldDoctor);
  if (oldUser || oldDoctor) {
    console.log("Email already exists error triggered");
    return next(
      appError.create("Email already exists", 400, httpStatusText.FAIL)
    );
  }

  const hashedPassword = await bcrypt.hash(password, 12);
  console.log("Password hashed successfully");

  if (role === userRoles.DOCTOR) {
    console.log("Processing doctor registration");
    const avatar = req.s3Data
      ? req.s3Data.url
      : `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/uploads/doctor.jpg`;
    console.log("Avatar determined:", avatar);
    const newDoctor = new Doctor({
      firstName,
      lastName,
      gender,
      phone,
      address,
      email,
      password: hashedPassword,
      role: userRoles.DOCTOR,
      specialise,
      about,
      rate,
      availableDays,
      availableTimes,
      avatar,
    });
    console.log("New doctor object created:", newDoctor);
    const token = await generateJWT(
      { email: newDoctor.email, id: newDoctor._id, role: newDoctor.role },
      "7d"
    );
    console.log("JWT token generated:", token);
    newDoctor.token = token;
    await newDoctor.save();
    console.log("Doctor saved to database:", newDoctor._id);
    const doctorData = {
      _id: newDoctor._id,
      firstName: newDoctor.firstName,
      lastName: newDoctor.lastName,
      gender: newDoctor.gender,
      phone: newDoctor.phone,
      address: newDoctor.address,
      email: newDoctor.email,
      role: newDoctor.role,
      specialise: newDoctor.specialise,
      about: newDoctor.about,
      rate: newDoctor.rate,
      availableDays: newDoctor.availableDays,
      availableTimes: newDoctor.availableTimes,
      avatar: newDoctor.avatar,
      created_at: newDoctor.created_at,
      token: newDoctor.token,
    };
    try {
      console.log("Attempting to send notification for new doctor");
      await sendNotificationCore(
        newDoctor._id,
        null,
        null,
        "Account Created",
        "Welcome! Your account has been created.",
        "profile",
        "doctor"
      );
      console.log("Notification sent for new doctor");
    } catch (error) {
      console.error(`Failed to send notification for new doctor: ${error}`);
    }
    res.status(201).json({
      status: httpStatusText.SUCCESS,
      message: "Doctor registered successfully",
      data: { user: doctorData },
    });
  } else {
    console.log("Processing user registration");
    const avatar = req.s3Data
      ? req.s3Data.url
      : `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/uploads/user-default.jpg`;
    console.log("Avatar determined:", avatar);
    const newUser = new User({
      firstName,
      lastName,
      gender,
      phone,
      address,
      email,
      password: hashedPassword,
      role,
      avatar,
    });
    console.log("New user object created:", newUser);
    const token = await generateJWT(
      { email: newUser.email, id: newUser._id, role: newUser.role },
      "7d"
    );
    console.log("JWT token generated:", token);
    newUser.token = token;
    await newUser.save();
    console.log("User saved to database:", newUser._id);
    const userData = {
      _id: newUser._id,
      firstName: newUser.firstName,
      lastName: newUser.lastName,
      gender: newUser.gender,
      phone: newUser.phone,
      address: newUser.address,
      email: newUser.email,
      role: newUser.role,
      avatar: newUser.avatar,
      favorite: newUser.favorite,
      created_at: newUser.created_at,
      token: newUser.token,
    };
    try {
      console.log("Attempting to send notification for new user");
      await sendNotificationCore(
        newUser._id,
        null,
        null,
        "Account Created",
        "Welcome! Your account has been created.",
        "profile",
        "patient"
      );
      console.log("Notification sent for new user");
    } catch (error) {
      console.error(`Failed to send notification for new user: ${error}`);
    }
    res.status(201).json({
      status: httpStatusText.SUCCESS,
      message: "User registered successfully",
      data: { user: userData },
    });
  }
});

const login = asyncWrapper(async (req, res, next) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return next(
      appError.create(
        "Email and Password are required",
        400,
        httpStatusText.FAIL
      )
    );
  }
  let user = await User.findOne({ email });
  let role;
  if (user) {
    role = user.role;
  } else {
    user = await Doctor.findOne({ email });
    if (user) {
      role = user.role;
    }
  }
  if (!user) {
    return next(appError.create("User not found", 400, httpStatusText.FAIL));
  }
  const isPasswordCorrect = await bcrypt.compare(password, user.password);
  if (isPasswordCorrect && user) {
    const token = await generateJWT(
      { email: user.email, id: user._id, role: role },
      "7d"
    );
    user.token = token;
    await user.save();
    res.status(200).json({
      status: httpStatusText.SUCCESS,
      data: {
        token: token,
        role: role,
      },
    });
  } else {
    return next(
      appError.create(
        "Email or Password are incorrect",
        500,
        httpStatusText.ERROR
      )
    );
  }
});

const getUserProfile = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;
  if (!userId) {
    return next(
      appError.create("User ID not found in token", 401, httpStatusText.FAIL)
    );
  }
  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can view their profile",
        403,
        httpStatusText.FAIL
      )
    );
  }
  const user = await User.findById(userId).select("-password -token");
  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }
  if (req.s3Data && req.s3Data.data) {
    console.log("Image data retrieved from S3:", req.s3Data.data);
  }
  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      firstName: user.firstName,
      lastName: user.lastName,
      gender: user.gender,
      phone: user.phone,
      address: user.address,
      email: user.email,
      role: user.role,
      avatar: user.avatar,
      favorite: user.favorite,
      created_at: user.created_at,
    },
  });
});

const updateProfile = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;
  const { firstName, lastName, email, phone, gender } = req.body;

  const user = await User.findById(userId);
  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  const changes = [];
  if (firstName && firstName !== user.firstName) {
    changes.push(`name to ${firstName}`);
    user.firstName = firstName;
  }
  if (lastName && lastName !== user.lastName) {
    changes.push(`last name to ${lastName}`);
    user.lastName = lastName;
  }
  if (email && email !== user.email) {
    changes.push(`email to ${email}`);
    user.email = email;
  }
  if (phone && phone !== user.phone) {
    changes.push(`phone to ${phone}`);
    user.phone = phone;
  }
  if (gender && gender !== user.gender) {
    changes.push(`gender to ${gender}`);
    user.gender = gender;
  }
  if (req.s3Data && req.s3Data.url) {
    changes.push(`avatar updated`);
    user.avatar = req.s3Data.url;
  }

  await user.save();

  if (changes.length > 0) {
    try {
      await sendNotificationCore(
        userId,
        null,
        null,
        "Profile Updated",
        `Updated: ${changes.join(", ")}`,
        "profile",
        "patient"
      );
    } catch (error) {
      console.error(
        `Failed to send notification for updated user profile: ${error}`
      );
    }
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "User profile updated successfully",
    data: {
      id: user._id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      gender: user.gender,
      role: user.role,
      avatar: user.avatar,
      createdAt: user.createdAt,
    },
  });
});

const deleteProfile = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;

  const user = await User.findById(userId);
  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    await Child.deleteMany({ parentId: userId }, { session });
    await Appointment.deleteMany({ userId }, { session });

    if (
      user.avatar &&
      user.avatar !==
        `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/uploads/user-default.jpg`
    ) {
      const key = user.avatar.split("/").pop();
      await deleteObject(key);
    }

    user.token = null;
    user.fcmToken = null;
    await user.save({ session });

    const deleteResult = await User.deleteOne({ _id: userId }, { session });
    if (deleteResult.deletedCount === 0) {
      throw new Error("Failed to delete user account");
    }

    await session.commitTransaction();

    try {
      await sendNotificationCore(
        userId,
        null,
        null,
        "Account Deleted",
        "Your account has been deleted.",
        "profile",
        "patient"
      );
    } catch (error) {
      console.error(
        `Failed to send notification for deleted user profile: ${error}`
      );
    }

    res.json({
      status: httpStatusText.SUCCESS,
      message: "User account deleted successfully",
    });
  } catch (error) {
    await session.abortTransaction();
    return next(
      appError.create(
        error.message || "Failed to delete user account",
        500,
        httpStatusText.ERROR
      )
    );
  } finally {
    session.endSession();
  }
});

const logout = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;

  const user = await User.findById(userId);
  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  user.token = null;
  user.fcmToken = null;
  await user.save();

  try {
    await sendNotificationCore(
      userId,
      null,
      null,
      "Logged Out",
      "You have logged out.",
      "general",
      "patient"
    );
  } catch (error) {
    console.error(`Failed to send notification for user logout: ${error}`);
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "User logged out successfully",
  });
});

const saveFcmToken = asyncWrapper(async (req, res, next) => {
  const { fcmToken } = req.body;
  const userId = req.user.id;

  if (!fcmToken) {
    return next(
      appError.create("FCM Token is required", 400, httpStatusText.FAIL)
    );
  }

  const user = await User.findById(userId);
  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  if (user.fcmToken === fcmToken) {
    return res.status(200).json({
      status: httpStatusText.SUCCESS,
      message: "FCM Token is already up to date",
    });
  }

  await User.updateMany({ fcmToken, _id: { $ne: userId } }, { fcmToken: null });

  user.fcmToken = fcmToken;
  await user.save();

  try {
    await sendNotificationCore(
      userId,
      null,
      null,
      "FCM Token Updated",
      "Notification settings updated.",
      "profile",
      "patient"
    );
  } catch (error) {
    console.error(`Failed to send notification for FCM token update: ${error}`);
  }

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    message: "FCM Token saved successfully",
  });
});

module.exports = {
  getAllUsers,
  register,
  login,
  getUserProfile,
  updateProfile,
  deleteProfile,
  logout,
  saveFcmToken,
};
