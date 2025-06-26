const asyncWrapper = require("../middlewares/asyncWrapper");
const Chat = require("../models/chat.model");
const Appointment = require("../models/appointment.model");
const Child = require("../models/child.model");
const Doctor = require("../models/doctor.model");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const { deleteObject } = require("../utils/s3-operations");

const verifyChatEligibility = async (childId, doctorId, userId, role, next) => {
  if (role !== "patient" && role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only patients or doctors can access chat",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const child = await Child.findOne({ _id: childId });
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  if (role === "patient") {
    const acceptedAppointment = await Appointment.findOne({
      childId,
      doctorId,
      status: "Accepted",
    });
    if (!acceptedAppointment) {
      return next(
        appError.create(
          "You must have at least one accepted appointment with this doctor to start a chat",
          403,
          httpStatusText.FAIL
        )
      );
    }
  }

  return true;
};

const checkChatEligibility = asyncWrapper(async (req, res, next) => {
  const { childId, doctorId } = req.params;
  const userId = req.user.id;

  await verifyChatEligibility(childId, doctorId, userId, req.user.role, next);

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    message: "Chat eligibility confirmed",
  });
});

const getChatHistory = asyncWrapper(async (req, res, next) => {
  const { childId, doctorId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== "patient" && req.user.role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only patients or doctors can access chat history",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (req.user.role === "patient") {
    const child = await Child.findOne({ _id: childId, parentId: userId });
    if (!child) {
      return next(
        appError.create(
          "Child not found or you are not authorized",
          404,
          httpStatusText.FAIL
        )
      );
    }
  }

  if (req.user.role === "doctor" && doctorId !== userId.toString()) {
    return next(
      appError.create(
        "Unauthorized: You can only access your own chats",
        403,
        httpStatusText.FAIL
      )
    );
  }

  let chat = await Chat.findOne({ childId, doctorId }).sort({
    "messages.timestamp": -1,
  });
  if (!chat) {
    chat = new Chat({
      childId,
      doctorId,
      messages: [],
    });
    await chat.save();
  }

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    data: { messages: chat.messages },
  });
});

const uploadMedia = asyncWrapper(async (req, res, next) => {
  const { childId, doctorId } = req.params;
  const userId = req.user.id;
  const io = req.app.get("io");

  await verifyChatEligibility(childId, doctorId, userId, req.user.role, next);

  const mediaUrl = req.s3Data ? req.s3Data.url : null;
  if (!mediaUrl) {
    return next(
      appError.create("No media file uploaded", 400, httpStatusText.FAIL)
    );
  }

  let chat = await Chat.findOne({ childId, doctorId });
  if (!chat) {
    chat = new Chat({
      childId,
      doctorId,
      messages: [],
    });
  }

  const message = {
    sender: req.user.role === "doctor" ? "doctor" : "child",
    media: mediaUrl,
    timestamp: new Date(),
  };

  chat.messages.push(message);
  await chat.save();

  io.to(`${childId}-${doctorId}`).emit("receiveMessage", message);

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    message: "Media uploaded successfully",
    data: { mediaUrl },
  });
});

module.exports = {
  checkChatEligibility,
  getChatHistory,
  uploadMedia,
};