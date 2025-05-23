// const asyncWrapper = require("../middlewares/asyncWrapper");
// const User = require("../models/user.model");
// const Doctor = require("../models/doctor.model");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");
// const bcrypt = require("bcryptjs");
// const generateJWT = require("../utils/genrate.JWT");
// const userRoles = require("../utils/userRoles");
// const mongoose = require("mongoose");
// const { sendNotification } = require("../controllers/notifications.controller");

// // Get all users
// const getAllUsers = asyncWrapper(async (req, res) => {
//   const users = await User.find({}, { __v: 0, password: false });
//   res.json({ status: httpStatusText.SUCCESS, data: { users } });
// });

// // جلب بيانات اليوزر (Profile)
// const getUserProfile = asyncWrapper(async (req, res, next) => {
//   const userId = req.user.id;
//   if (!userId) {
//     return next(
//       appError.create("User ID not found in token", 401, httpStatusText.FAIL)
//     );
//   }
//   if (req.user.role !== userRoles.PATIENT) {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can view their profile",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }
//   const user = await User.findById(userId).select("-password -token");
//   if (!user) {
//     return next(appError.create("User not found", 404, httpStatusText.FAIL));
//   }
//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       firstName: user.firstName,
//       lastName: user.lastName,
//       gender: user.gender,
//       phone: user.phone,
//       address: user.address,
//       email: user.email,
//       role: user.role,
//       avatar: user.avatar,
//       favorite: user.favorite,
//       created_at: user.created_at,
//     },
//   });
// });

// // تعديل بيانات اليوزر (Profile)
// const updateUserProfile = asyncWrapper(async (req, res, next) => {
//   const userId = req.user.id;
//   const { firstName, lastName, email, phone, address } = req.body;

//   if (req.user.role !== userRoles.PATIENT) {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can update their profile",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const user = await User.findById(userId);
//   if (!user) {
//     return next(appError.create("User not found", 404, httpStatusText.FAIL));
//   }

//   // دعم multer: إذا كان هناك ملف مرفوع، استخدم مساره لتحديث avatar
//   const avatar = req.file ? `/uploads/${req.file.filename}` : undefined;

//   const changes = [];
//   if (firstName && firstName !== user.firstName) {
//     changes.push(`name to ${firstName}`);
//     user.firstName = firstName;
//   }
//   if (lastName && lastName !== user.lastName) {
//     changes.push(`last name to ${lastName}`);
//     user.lastName = lastName;
//   }
//   if (email && email !== user.email) {
//     const existingUser = await User.findOne({ email });
//     if (existingUser && existingUser._id.toString() !== userId.toString()) {
//       return next(
//         appError.create("Email already exists", 400, httpStatusText.FAIL)
//       );
//     }
//     changes.push(`email to ${email}`);
//     user.email = email;
//   }
//   if (phone && phone !== user.phone) {
//     changes.push(`phone to ${phone}`);
//     user.phone = phone;
//   }
//   if (address && address !== user.address) {
//     changes.push(`address to ${address}`);
//     user.address = address;
//   }
//   if (avatar) {
//     changes.push(`avatar updated`);
//     user.avatar = avatar;
//   }

//   await user.save();

//   if (changes.length > 0) {
//     try {
//       await sendNotification(
//         userId,
//         null,
//         null,
//         "Profile Updated",
//         `Updated: ${changes.join(", ")}`,
//         "profile",
//         "patient"
//       );
//       console.log(
//         `Notification sent for profile update: ${changes.join(", ")}`
//       );
//     } catch (error) {
//       console.error(
//         `Failed to send profile update notification: ${error.message}`
//       );
//     }
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Profile updated successfully",
//     data: {
//       firstName: user.firstName,
//       lastName: user.lastName,
//       gender: user.gender,
//       phone: user.phone,
//       address: user.address,
//       email: user.email,
//       role: user.role,
//       avatar: user.avatar,
//       favorite: user.favorite,
//       created_at: user.created_at,
//     },
//   });
// });

// // حذف الأكونت بتاع اليوزر
// const deleteUserProfile = asyncWrapper(async (req, res, next) => {
//   const userId = req.user.id;
//   const userEmail = req.user.email;
//   if (!userId) {
//     return next(
//       appError.create("User ID not found in token", 401, httpStatusText.FAIL)
//     );
//   }
//   if (!mongoose.Types.ObjectId.isValid(userId)) {
//     return next(
//       appError.create("Invalid User ID in token", 400, httpStatusText.FAIL)
//     );
//   }
//   if (req.user.role !== userRoles.PATIENT) {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can delete their profile",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }
//   const user = await User.findById(userId);
//   if (!user) {
//     return next(appError.create("User not found", 404, httpStatusText.FAIL));
//   }
//   if (user.email !== userEmail) {
//     return next(
//       appError.create("Unauthorized: Email mismatch", 403, httpStatusText.FAIL)
//     );
//   }
//   const session = await mongoose.startSession();
//   session.startTransaction();
//   try {
//     user.token = null;
//     await user.save({ session });
//     const deleteResult = await User.deleteOne({ _id: userId }, { session });
//     if (deleteResult.deletedCount === 0) {
//       throw new Error("Failed to delete user account");
//     }
//     await sendNotification(
//       userId,
//       null,
//       null,
//       "Account Deleted",
//       "Your account has been deleted.",
//       "profile",
//       "patient"
//     );
//     await session.commitTransaction();
//     res.json({
//       status: httpStatusText.SUCCESS,
//       message: "User account deleted successfully",
//     });
//   } catch (error) {
//     await session.abortTransaction();
//     return next(
//       appError.create(
//         error.message || "Failed to delete user account",
//         500,
//         httpStatusText.ERROR
//       )
//     );
//   } finally {
//     session.endSession();
//   }
// });

// // تسجيل الخروج لليوزر
// const logoutUser = asyncWrapper(async (req, res, next) => {
//   const userId = req.user.id;
//   if (req.user.role !== userRoles.PATIENT) {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can logout",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }
//   const user = await User.findById(userId);
//   if (!user) {
//     return next(appError.create("User not found", 404, httpStatusText.FAIL));
//   }
//   user.token = null;
//   await user.save();
//   await sendNotification(
//     userId,
//     null,
//     null,
//     "Logged Out",
//     "You have logged out.",
//     "general",
//     "patient"
//   );
//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Logged out successfully",
//   });
// });

// // Register New User or Doctor
// const registerUser = asyncWrapper(async (req, res, next) => {
//   const {
//     firstName,
//     lastName,
//     gender,
//     phone,
//     address,
//     email,
//     password,
//     role,
//     specialise,
//     about,
//     rate,
//     availableDays,
//     availableTimes,
//   } = req.body;
//   const oldUser = await User.findOne({ email });
//   const oldDoctor = await Doctor.findOne({ email });
//   if (oldUser || oldDoctor) {
//     return next(
//       appError.create("Email already exists", 400, httpStatusText.FAIL)
//     );
//   }
//   const hashedPassword = await bcrypt.hash(password, 12);
//   if (role === userRoles.DOCTOR) {
//     const avatar = req.file
//       ? `/uploads/${req.file.filename}`
//       : "uploads/doctor.jpg";
//     const newDoctor = new Doctor({
//       firstName,
//       lastName,
//       gender,
//       phone,
//       address,
//       email,
//       password: hashedPassword,
//       role: userRoles.DOCTOR,
//       specialise,
//       about,
//       rate,
//       availableDays,
//       availableTimes,
//       avatar,
//     });
//     const token = await generateJWT(
//       { email: newDoctor.email, id: newDoctor._id, role: newDoctor.role },
//       "7d"
//     );
//     newDoctor.token = token;
//     await newDoctor.save();
//     const doctorData = {
//       _id: newDoctor._id,
//       firstName: newDoctor.firstName,
//       lastName: newDoctor.lastName,
//       gender: newDoctor.gender,
//       phone: newDoctor.phone,
//       address: newDoctor.address,
//       email: newDoctor.email,
//       role: newDoctor.role,
//       specialise: newDoctor.specialise,
//       about: newDoctor.about,
//       rate: newDoctor.rate,
//       availableDays: newDoctor.availableDays,
//       availableTimes: newDoctor.availableTimes,
//       avatar: newDoctor.avatar,
//       created_at: newDoctor.created_at,
//       token: newDoctor.token,
//     };
//     await sendNotification(
//       newDoctor._id,
//       null,
//       null,
//       "Account Created",
//       "Welcome! Your account has been created.",
//       "profile",
//       "doctor"
//     );
//     res.status(201).json({
//       status: httpStatusText.SUCCESS,
//       message: "Doctor registered successfully",
//       data: { user: doctorData },
//     });
//   } else {
//     const avatar = req.file
//       ? `/uploads/${req.file.filename}`
//       : "uploads/profile.jpg";
//     const newUser = new User({
//       firstName,
//       lastName,
//       gender,
//       phone,
//       address,
//       email,
//       password: hashedPassword,
//       role: userRoles.PATIENT,
//       avatar,
//     });
//     const token = await generateJWT(
//       { email: newUser.email, id: newUser._id, role: newUser.role },
//       "7d"
//     );
//     newUser.token = token;
//     await newUser.save();
//     const userData = {
//       _id: newUser._id,
//       firstName: newUser.firstName,
//       lastName: newUser.lastName,
//       gender: newUser.gender,
//       phone: newUser.phone,
//       address: newUser.address,
//       email: newUser.email,
//       role: newUser.role,
//       avatar: newUser.avatar,
//       favorite: newUser.favorite,
//       created_at: newUser.created_at,
//       token: newUser.token,
//     };
//     await sendNotification(
//       newUser._id,
//       null,
//       null,
//       "Account Created",
//       "Welcome! Your account has been created.",
//       "profile",
//       "patient"
//     );
//     res.status(201).json({
//       status: httpStatusText.SUCCESS,
//       message: "User registered successfully",
//       data: { user: userData },
//     });
//   }
// });

// // Login User or Doctor
// const loginUser = asyncWrapper(async (req, res, next) => {
//   const { email, password } = req.body;
//   if (!email || !password) {
//     return next(
//       appError.create(
//         "Email and Password are required",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }
//   let user = await User.findOne({ email });
//   let role;
//   if (user) {
//     role = user.role;
//   } else {
//     user = await Doctor.findOne({ email });
//     if (user) {
//       role = user.role;
//     }
//   }
//   if (!user) {
//     return next(appError.create("User not found", 400, httpStatusText.FAIL));
//   }
//   const isPasswordCorrect = await bcrypt.compare(password, user.password);
//   if (isPasswordCorrect && user) {
//     const token = await generateJWT(
//       { email: user.email, id: user._id, role: role },
//       "7d"
//     );
//     user.token = token;
//     await user.save();
//     await sendNotification(
//       user._id,
//       null,
//       null,
//       "Logged In",
//       "You have logged in successfully.",
//       "general",
//       role === userRoles.DOCTOR ? "doctor" : "patient"
//     );
//     res.status(200).json({
//       status: httpStatusText.SUCCESS,
//       data: {
//         token: token,
//         role: role,
//       },
//     });
//   } else {
//     return next(
//       appError.create(
//         "Email or Password are incorrect",
//         500,
//         httpStatusText.ERROR
//       )
//     );
//   }
// });

// // Save FCM Token for user
// const saveFcmToken = asyncWrapper(async (req, res, next) => {
//   const { fcmToken } = req.body;
//   const userId = req.user.id;
//   if (!fcmToken) {
//     return next(
//       appError.create("FCM Token is required", 400, httpStatusText.FAIL)
//     );
//   }
//   if (req.user.role !== userRoles.PATIENT) {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can save FCM Token",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }
//   const user = await User.findById(userId);
//   if (!user) {
//     return next(appError.create("User not found", 404, httpStatusText.FAIL));
//   }
//   if (user.fcmToken === fcmToken) {
//     return res.status(200).json({
//       status: httpStatusText.SUCCESS,
//       message: "FCM Token is already up to date",
//     });
//   }
//   await User.updateMany({ fcmToken, _id: { $ne: userId } }, { fcmToken: null });
//   user.fcmToken = fcmToken;
//   await user.save();
//   await sendNotification(
//     userId,
//     null,
//     null,
//     "FCM Token Updated",
//     "Notification settings updated.",
//     "profile",
//     "patient"
//   );
//   res.status(200).json({
//     status: httpStatusText.SUCCESS,
//     message: "FCM Token saved successfully",
//   });
// });

// module.exports = {
//   getAllUsers,
//   registerUser,
//   loginUser,
//   getUserProfile,
//   updateUserProfile,
//   deleteUserProfile,
//   logoutUser,
//   saveFcmToken,
// };

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

// Register New User or Doctor
const register = asyncWrapper(async (req, res, next) => {
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
  const oldUser = await User.findOne({ email });
  const oldDoctor = await Doctor.findOne({ email });
  if (oldUser || oldDoctor) {
    return next(
      appError.create("Email already exists", 400, httpStatusText.FAIL)
    );
  }
  const hashedPassword = await bcrypt.hash(password, 12);
  if (role === userRoles.DOCTOR) {
    const avatar = req.file
      ? `/uploads/${req.file.filename}`
      : "Uploads/doctor.jpg";
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
    const token = await generateJWT(
      { email: newDoctor.email, id: newDoctor._id, role: newDoctor.role },
      "7d"
    );
    newDoctor.token = token;
    await newDoctor.save();
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
      await sendNotificationCore(
        newDoctor._id,
        null,
        null,
        "Account Created",
        "Welcome! Your account has been created.",
        "profile",
        "doctor"
      );
      console.log(`Notification sent for new doctor: ${newDoctor.firstName}`);
    } catch (error) {
      console.error(
        `Failed to send notification for new doctor: ${newDoctor.firstName}`,
        error
      );
    }
    res.status(201).json({
      status: httpStatusText.SUCCESS,
      message: "Doctor registered successfully",
      data: { user: doctorData },
    });
  } else {
    const avatar = req.file
      ? `/Uploads/${req.file.filename}`
      : "Uploads/profile.jpg";
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
    const token = await generateJWT(
      { email: newUser.email, id: newUser._id, role: newUser.role },
      "7d"
    );
    newUser.token = token;
    await newUser.save();
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
      await sendNotificationCore(
        newUser._id,
        null,
        null,
        "Account Created",
        "Welcome! Your account has been created.",
        "profile",
        "patient"
      );
      console.log(`Notification sent for new user: ${newUser.firstName}`);
    } catch (error) {
      console.error(
        `Failed to send notification for new user: ${newUser.firstName}`,
        error
      );
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
  if (req.file) {
    changes.push(`avatar updated`);
    user.avatar = `/uploads/${req.file.filename}`;
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
      console.log(
        `Notification sent for updated user profile: ${user.firstName}`
      );
    } catch (error) {
      console.error(
        `Failed to send notification for updated user profile: ${user.firstName}`,
        error
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
      console.log(
        `Notification sent for deleted user profile: ${user.firstName}`
      );
    } catch (error) {
      console.error(
        `Failed to send notification for deleted user profile: ${user.firstName}`,
        error
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
    console.log(`Notification sent for user logout: ${user.firstName}`);
  } catch (error) {
    console.error(
      `Failed to send notification for user logout: ${user.firstName}`,
      error
    );
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
    console.log(`Notification sent for FCM token update: ${user.firstName}`);
  } catch (error) {
    console.error(
      `Failed to send notification for FCM token update: ${user.firstName}`,
      error
    );
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