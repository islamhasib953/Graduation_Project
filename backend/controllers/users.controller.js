// const asyncWrapper = require("../middlewares/asyncWrapper");
// const User = require("../models/user.model");
// const Doctor = require("../models/doctor.model");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");
// const bcrypt = require("bcryptjs");
// const genrateJWT = require("../utils/genrate.JWT");
// const userRoles = require("../utils/userRoles");
// const mongoose = require("mongoose");

// // Get all users
// const getAllUsers = asyncWrapper(async (req, res) => {
//   const users = await User.find({}, { __v: 0, password: false });
//   res.json({ status: httpStatusText.SUCCESS, data: { users } });
// });


// // // Get a single user by ID
// // const getUserById = asyncWrapper(async (req, res, next) => {
// //   const { userId } = req.params;

// //   const user = await User.findById(userId);

// //   if (!user) {
// //     return next(appError.create("User not found", 404, httpStatusText.FAIL));
// //   }

// //   res.json({ status: httpStatusText.SUCCESS, data: { user } });
// // });

// // ✅ جلب بيانات اليوزر (Profile)
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

// // ✅ تعديل بيانات اليوزر (Profile)
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

//   if (firstName) user.firstName = firstName;
//   if (lastName) user.lastName = lastName;
//   if (email) user.email = email;
//   if (phone) user.phone = phone;
//   if (address) user.address = address;

//   await user.save();

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

// // ✅ حذف الأكونت بتاع اليوزر (مع مسح الـ Token)
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

//   // استخدام Transaction للتأكد من إن كل العمليات بتتم مع بعض
//   const session = await mongoose.startSession();
//   session.startTransaction();

//   try {
//     user.token = null;
//     await user.save({ session });

//     const deleteResult = await User.deleteOne({ _id: userId }, { session });
//     if (deleteResult.deletedCount === 0) {
//       throw new Error("Failed to delete user account");
//     }

//     // Commit الـ Transaction
//     await session.commitTransaction();

//     res.json({
//       status: httpStatusText.SUCCESS,
//       message: "User account deleted successfully",
//     });
//   } catch (error) {
//     // Rollback الـ Transaction لو حصل أي خطأ
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

// // ✅ تسجيل الخروج لليوزر
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
//     const error = appError.create(
//       "Email already exists",
//       400,
//       httpStatusText.FAIL
//     );
//     return next(error);
//   }

//   const hashedPassword = await bcrypt.hash(password, 12);

//   if (role === userRoles.DOCTOR) {
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
//       avatar: req.file ? req.file.filename : "uploads/doctor.jpg",
//     });

//     const token = await genrateJWT(
//       {
//         email: newDoctor.email,
//         id: newDoctor._id,
//         role: newDoctor.role,
//       },
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

//     res.status(201).json({
//       status: httpStatusText.SUCCESS,
//       message: "Doctor registered successfully",
//       data: { user: doctorData },
//     });
//   } else {
//     const newUser = new User({
//       firstName,
//       lastName,
//       gender,
//       phone,
//       address,
//       email,
//       password: hashedPassword,
//       role: userRoles.PATIENT,
//       avatar: req.file ? req.file.filename : "uploads/profile.jpg",
//     });

//     const token = await genrateJWT(
//       {
//         email: newUser.email,
//         id: newUser._id,
//         role: newUser.role,
//       },
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
//     const error = appError.create(
//       "Email and Password are required",
//       400,
//       httpStatusText.FAIL
//     );
//     return next(error);
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
//     const error = appError.create("User not found", 400, httpStatusText.FAIL);
//     return next(error);
//   }

//   const isPasswordCorrect = await bcrypt.compare(password, user.password);
//   if (isPasswordCorrect && user) {
//     const token = await genrateJWT(
//       {
//         email: user.email,
//         id: user._id,
//         role: role,
//       },
//       "7d"
//     );

//     res.status(200).json({
//       status: httpStatusText.SUCCESS,
//       data: {
//         token: token,
//         role: role,
//       },
//     });
//   } else {
//     const error = appError.create(
//       "Email or Password are incorrect",
//       500,
//       httpStatusText.ERROR
//     );
//     return next(error);
//   }
// });

// // Update user details
// // const updateUser = asyncWrapper(async (req, res, next) => {
// //   const { userId } = req.params;
// //   const { firstName, lastName, gender, phone, address, password, avatar } =
// //     req.body;

// //   let updateData = { firstName, lastName, gender, phone, address };

// //   if (password) {
// //     const hashedPassword = await bcrypt.hash(password, 12);
// //     updateData.password = hashedPassword;
// //   }

// //   if (req.file) {
// //     updateData.avatar = req.file.filename;
// //   }

// //   const updatedUser = await User.findByIdAndUpdate(userId, updateData, {
// //     new: true,
// //   });

// //   if (!updatedUser) {
// //     return next(appError.create("User not found", 404, httpStatusText.FAIL));
// //   }

// //   res.json({ status: httpStatusText.SUCCESS, data: { user: updatedUser } });
// // });

// // // Delete a user
// // const deleteUser = asyncWrapper(async (req, res, next) => {
// //   const { userId } = req.params;
// //   const deletedUser = await User.findByIdAndDelete(userId);

// //   if (!deletedUser) {
// //     return next(appError.create("User not found", 404, httpStatusText.FAIL));
// //   }

// //   res.json({
// //     status: httpStatusText.SUCCESS,
// //     message: "User deleted successfully",
// //   });
// // });

// module.exports = {
//   getAllUsers,
//   registerUser,
//   loginUser,
//   // getUserById,
//   // updateUser,
//   // deleteUser,
//   getUserProfile,
//   updateUserProfile,
//   deleteUserProfile,
//   logoutUser,
// };


const asyncWrapper = require("../middlewares/asyncWrapper");
const User = require("../models/user.model");
const Doctor = require("../models/doctor.model");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const bcrypt = require("bcryptjs");
const genrateJWT = require("../utils/genrate.JWT");
const userRoles = require("../utils/userRoles");
const mongoose = require("mongoose");
const { sendNotification } = require("../controllers/notifications.controller");

// Get all users
const getAllUsers = asyncWrapper(async (req, res) => {
  const users = await User.find({}, { __v: 0, password: false });
  res.json({ status: httpStatusText.SUCCESS, data: { users } });
});

// ✅ جلب بيانات اليوزر (Profile)
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

// ✅ Register a new user
const registerUser = asyncWrapper(async (req, res, next) => {
  const { firstName, lastName, email, password, phone, address, gender } = req.body;

  if (!firstName || !lastName || !email || !password || !phone || !address || !gender) {
    return next(
      appError.create("All fields are required", 400, httpStatusText.FAIL)
    );
  }

  const user = await User.findOne({ email });
  if (user) {
    return next(
      appError.create("Email already exists", 400, httpStatusText.FAIL)
    );
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  const newUser = new User({
    firstName,
    lastName,
    email,
    password: hashedPassword,
    phone,
    address,
    gender,
    role: userRoles.PATIENT,
  });

  const token = await genrateJWT({ email: newUser.email, id: newUser._id, role: newUser.role });
  newUser.token = token;

  await newUser.save();

  // إرسال إشعار مختصر
  await sendNotification(
    newUser._id,
    null,
    null,
    "Account Created",
    "Welcome! Your account has been created.",
    "user",
    "patient" // تغيير من "user" إلى "patient"
  );

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: {
      user: {
        firstName: newUser.firstName,
        lastName: newUser.lastName,
        email: newUser.email,
        phone: newUser.phone,
        address: newUser.address,
        gender: newUser.gender,
        role: newUser.role,
        token: newUser.token,
      },
    },
  });
});

// ✅ Login user
const loginUser = asyncWrapper(async (req, res, next) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return next(
      appError.create("Email and password are required", 400, httpStatusText.FAIL)
    );
  }

  const user = await User.findOne({ email });
  if (!user) {
    return next(
      appError.create("User not found", 404, httpStatusText.FAIL)
    );
  }

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) {
    return next(
      appError.create("Invalid credentials", 401, httpStatusText.FAIL)
    );
  }

  const token = await genrateJWT({ email: user.email, id: user._id, role: user.role });
  user.token = token;
  await user.save();

  // إرسال إشعار مختصر
  await sendNotification(
    user._id,
    null,
    null,
    "Logged In",
    "You have logged in successfully.",
    "login",
    "patient" // تغيير من "user" إلى "patient"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      user: {
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        address: user.address,
        gender: user.gender,
        role: user.role,
        token: user.token,
      },
    },
  });
});

// ✅ Update user profile
const updateUserProfile = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;
  const { firstName, lastName, email, phone, address, gender } = req.body;

  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can update their profile",
        403,
        httpStatusText.FAIL
      )
    );
  }

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
    const existingUser = await User.findOne({ email });
    if (existingUser && existingUser._id.toString() !== userId.toString()) {
      return next(
        appError.create("Email already exists", 400, httpStatusText.FAIL)
      );
    }
    changes.push(`email to ${email}`);
    user.email = email;
  }
  if (phone && phone !== user.phone) {
    changes.push(`phone to ${phone}`);
    user.phone = phone;
  }
  if (address && address !== user.address) {
    changes.push(`address to ${address}`);
    user.address = address;
  }
  if (gender && gender !== user.gender) {
    changes.push(`gender to ${gender}`);
    user.gender = gender;
  }

  await user.save();

  // إرسال إشعار مختصر مع التغييرات فقط
  if (changes.length > 0) {
    await sendNotification(
      userId,
      null,
      null,
      "Profile Updated",
      `Updated: ${changes.join(", ")}`,
      "user",
      "patient" // تغيير من "user" إلى "patient"
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "User profile updated successfully",
    data: {
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      address: user.address,
      gender: user.gender,
      role: user.role,
      avatar: user.avatar,
    },
  });
});

// ✅ Delete user profile
const deleteUserProfile = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;

  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can delete their profile",
        403,
        httpStatusText.FAIL
      )
    );
  }

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

    // إرسال إشعار مختصر
    await sendNotification(
      userId,
      null,
      null,
      "Account Deleted",
      "Your account has been deleted.",
      "user",
      "patient" // تغيير من "user" إلى "patient"
    );

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

// ✅ Logout user
const logoutUser = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;

  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can logout",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const user = await User.findById(userId);
  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  user.token = null;
  user.fcmToken = null;
  await user.save();

  // إرسال إشعار مختصر
  await sendNotification(
    userId,
    null,
    null,
    "Logged Out",
    "You have logged out.",
    "logout",
    "patient" // تغيير من "user" إلى "patient"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    message: "User logged out successfully",
  });
});

// ✅ Save FCM Token for user
const saveFcmToken = asyncWrapper(async (req, res, next) => {
  const { fcmToken } = req.body;
  const userId = req.user.id;

  if (!fcmToken) {
    return next(
      appError.create("FCM Token is required", 400, httpStatusText.FAIL)
    );
  }

  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can save FCM Token",
        403,
        httpStatusText.FAIL
      )
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

  await User.updateMany(
    { fcmToken, _id: { $ne: userId } },
    { fcmToken: null }
  );

  user.fcmToken = fcmToken;
  await user.save();

  await sendNotification(
    userId,
    null,
    null,
    "FCM Token Updated",
    "Notification settings updated.",
    "user",
    "patient" // تغيير من "user" إلى "patient"
  );

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    message: "FCM Token saved successfully",
  });
});

module.exports = {
  getAllUsers,
  getUserProfile,
  registerUser,
  loginUser,
  updateUserProfile,
  deleteUserProfile,
  logoutUser,
  saveFcmToken,
};