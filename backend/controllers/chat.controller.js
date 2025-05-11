const asyncWrapper = require("../middlewares/asyncWrapper");
const Chat = require("../models/chat.model");
const Appointment = require("../models/appointment.model");
const Child = require("../models/child.model");
const Doctor = require("../models/doctor.model");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");

const checkChatEligibility = asyncWrapper(async (req, res, next) => {
  const { childId, doctorId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== "patient") {
    return next(
      appError.create(
        "Unauthorized: Only patients can access chat",
        403,
        httpStatusText.FAIL
      )
    );
  }

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

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

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

  let chat = await Chat.findOne({ childId, doctorId });
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

  if (req.user.role !== "patient") {
    return next(
      appError.create(
        "Unauthorized: Only patients can upload media",
        403,
        httpStatusText.FAIL
      )
    );
  }

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

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const acceptedAppointment = await Appointment.findOne({
    childId,
    doctorId,
    status: "Accepted",
  });

  if (!acceptedAppointment) {
    return next(
      appError.create(
        "You must have at least one accepted appointment with this doctor to send media",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const mediaUrl = req.file ? `/uploads/${req.file.filename}` : null;

  let chat = await Chat.findOne({ childId, doctorId });
  if (!chat) {
    chat = new Chat({
      childId,
      doctorId,
      messages: [],
    });
  }

  chat.messages.push({
    sender: "child",
    media: mediaUrl,
    timestamp: new Date(),
  });
  await chat.save();

  io.to(`${childId}-${doctorId}`).emit("receiveMessage", {
    sender: "child",
    media: mediaUrl,
    timestamp: new Date(),
  });

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
