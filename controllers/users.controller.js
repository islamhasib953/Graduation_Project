const asyncWrapper = require("../middlewares/asyncWrapper");
const User = require("../models/user.model");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const bcrypt = require("bcryptjs");
const genrateJWT = require("../utils/genrate.JWT");

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

// Register New User
const registerUser = asyncWrapper(async (req, res, next) => {
  const { firstName, lastName, gender, phone, address, email, password, role } =
    req.body;
  // console.log("req.file -> ", req.file);
  const oldUser = await User.findOne({ email: email });
  if (oldUser) {
    const error = appError.create(
      "User already exist",
      400,
      httpStatusText.FAIL
    );
    return next(error);
  }
  //passwird hasing
  const hashedPassword = await bcrypt.hash(password, 12);

  const newUser = new User({
    firstName,
    lastName,
    gender,
    phone,
    address,
    email,
    password: hashedPassword,
    role,
    avatar: req.file ? req.file.filename : "uploads/profile.jpg", // if user uploaded photo, save it in uploads folder and save path in database. Else, save default profile photo.  // req.file.path ==> path of uploaded photo  // req.file.originalname ==> name of uploaded photo  // req.file.mimetype ==> type of uploaded photo (like jpg, png, etc)  // req.file.size ==> size
  });

  //genrate JWT token
      const accessToken = await genrateJWT(
        {
          email: newUser.email,
          id: newUser._id,
          role: newUser.role,
        },
        "7d"
      );
  newUser.token = accessToken;

  //save new user in database
  await newUser.save();
  res
    .status(201)
    .json({ status: httpStatusText.SUCCESS, data: { user: newUser } });
});

//login New User
const loginUser = asyncWrapper(async (req, res, next) => {
  const { email, password } = req.body;
  if (!email && !password) {
    const error = appError.create(
      "Email and Password are required",
      400,
      httpStatusText.FAIL
    );
    return next(error);
  }

  const user = await User.findOne({ email: email });
  if (!user) {
    const error = appError.create("user not found", 400, httpStatusText.FAIL);
    return next(error);
  }

  const isPasswordCorrect = await bcrypt.compare(password, user.password);
  if (isPasswordCorrect && user) {
    // genrate accessToken
    const accessToken = await genrateJWT(
      {
        email: user.email,
        id: user._id,
        role: user.role,
      },
      "7d"
    );
    // genrate refreshToken
  //   const refreshToken = await genrateJWT(
  //     {
  //       email: user.email,
  //       id: user._id,
  //       role: user.role,
  //     },
  //     "7d"
  //   );
  // user.refreshToken = refreshToken;
  await user.save();

    res.status(200).json({
      status: httpStatusText.SUCCESS,
      data: { accessToken },
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
