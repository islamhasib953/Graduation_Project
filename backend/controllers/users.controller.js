const asyncWrapper = require("../middlewares/asyncWrapper");
const User = require("../models/user.model");
const Doctor = require("../models/doctor.model"); // أضفنا موديل الدكتور
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const bcrypt = require("bcryptjs");
const genrateJWT = require("../utils/genrate.JWT");
const userRoles = require("../utils/userRoles"); // أضفنا userRoles

// Get all users
const getAllUsers = asyncWrapper(async (req, res) => {
  const users = await User.find({}, { __v: 0, password: false });
  res.json({ status: httpStatusText.SUCCESS, data: { users } });
});

// Get a single user by ID
const getUserById = asyncWrapper(async (req, res, next) => {
  const { userId } = req.params;

  const user = await User.findById(userId);

  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  res.json({ status: httpStatusText.SUCCESS, data: { user } });
});

// Register New User or Doctor
const registerUser = asyncWrapper(async (req, res, next) => {
  const {
    firstName,
    lastName,
    gender,
    phone,
    address,
    email,
    password,
    role, // التعديل هنا: استبدلنا role بـ accountType
    specialise,
    about,
    rate,
    availableDays,
    availableTimes,
  } = req.body;

  // التحقق إن الإيميل مش مستخدم قبل كده في أي موديل (User أو Doctor)
  const oldUser = await User.findOne({ email });
  const oldDoctor = await Doctor.findOne({ email });
  if (oldUser || oldDoctor) {
    const error = appError.create(
      "Email already exists",
      400,
      httpStatusText.FAIL
    );
    return next(error);
  }

  // هاش الباسورد
  const hashedPassword = await bcrypt.hash(password, 12);

  // بناءً على accountType، هنحدد الموديل اللي هنستخدمه
  if (role === userRoles.DOCTOR) {
    const newDoctor = new Doctor({
      firstName,
      lastName,
      gender,
      phone,
      address,
      email,
      password: hashedPassword,
      role, // الـ role بيتحدد تلقائيًا
      specialise,
      about,
      rate,
      availableDays,
      availableTimes,
      avatar: req.file ? req.file.filename : "uploads/doctor.jpg",
    });

    // إنشاء توكن للدكتور
    const token = await genrateJWT(
      {
        email: newDoctor.email,
        id: newDoctor._id,
        role: newDoctor.role,
      },
      "7d"
    );
    newDoctor.token = token;

    // حفظ الدكتور
    await newDoctor.save();

    res.status(201).json({
      status: httpStatusText.SUCCESS,
      message: "Doctor registered successfully",
      data: { user: newDoctor },
    });
  } else {
    const newUser = new User({
      firstName,
      lastName,
      gender,
      phone,
      address,
      email,
      password: hashedPassword,
      role, // الـ role بيتحدد تلقائيًا
      avatar: req.file ? req.file.filename : "uploads/profile.jpg",
    });

    // إنشاء توكن لليوزر
    const token = await genrateJWT(
      {
        email: newUser.email,
        id: newUser._id,
        role: newUser.role,
      },
      "7d"
    );
    newUser.token = token;

    // حفظ اليوزر
    await newUser.save();

    res.status(201).json({
      status: httpStatusText.SUCCESS,
      message: "User registered successfully",
      data: { user: newUser },
    });
  }
});

// Login User or Doctor
const loginUser = asyncWrapper(async (req, res, next) => {
  const { email, password } = req.body;
  if (!email || !password) {
    const error = appError.create(
      "Email and Password are required",
      400,
      httpStatusText.FAIL
    );
    return next(error);
  }

  // التحقق من الإيميل في موديل اليوزر أو الدكتور
  let user = await User.findOne({ email });
  let role = userRoles.PATIENT;
  // let accountType = "patient"; // تحديد الـ accountType بناءً على الـ role

  if (!user) {
    user = await Doctor.findOne({ email });
    role = userRoles.DOCTOR;
    // accountType = "doctor"; // تحديد الـ accountType للدكتور
  }

  if (!user) {
    const error = appError.create("User not found", 400, httpStatusText.FAIL);
    return next(error);
  }

  const isPasswordCorrect = await bcrypt.compare(password, user.password);
  if (isPasswordCorrect && user) {
    // إنشاء توكن
    const token = await genrateJWT(
      {
        email: user.email,
        id: user._id,
        role: role,
      },
      "7d"
    );

    res.status(200).json({
      status: httpStatusText.SUCCESS,
      data: {
        token: token,
        role: role, // إضافة الـ accountType في الـ Response
      },
    });
  } else {
    const error = appError.create(
      "Email or Password are incorrect",
      500,
      httpStatusText.ERROR
    );
    return next(error);
  }
});


// Update user details
const updateUser = asyncWrapper(async (req, res, next) => {
  const { userId } = req.params;
  const { firstName, lastName, gender, phone, address, password, avatar } =
    req.body;

  let updateData = { firstName, lastName, gender, phone, address };

  // If a new password is provided, hash it before updating
  if (password) {
    const hashedPassword = await bcrypt.hash(password, 12);
    updateData.password = hashedPassword;
  }

  // Handle avatar update if a file is uploaded
  if (req.file) {
    updateData.avatar = req.file.filename;
  }

  const updatedUser = await User.findByIdAndUpdate(userId, updateData, {
    new: true,
  });

  if (!updatedUser) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  res.json({ status: httpStatusText.SUCCESS, data: { user: updatedUser } });
});

// Delete a user
const deleteUser = asyncWrapper(async (req, res, next) => {
  const { userId } = req.params;
  const deletedUser = await User.findByIdAndDelete(userId);

  if (!deletedUser) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "User deleted successfully",
  });
});

module.exports = {
  getAllUsers,
  registerUser,
  loginUser,
  getUserById,
  updateUser,
  deleteUser,
};
//***** */