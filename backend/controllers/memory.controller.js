const Memory = require("../models/memory.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const {
  sendNotificationCore,
} = require("../controllers/notifications.controller");
const { deleteObject } = require("../utils/s3-operations");

const createMemory = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;
  const { description, date, time } = req.body;

  if (!description || !time) {
    return next(
      appError.create(
        "Description and time are required",
        400,
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

  const image = req.s3Data ? req.s3Data.url : undefined;

  const newMemory = new Memory({
    childId,
    description,
    date: date || undefined,
    time,
    image,
  });

  await newMemory.save();

  try {
    await sendNotificationCore(
      userId,
      childId,
      null,
      "Memory Added",
      `${child.name}: ${description} added.`,
      "memory",
      "patient"
    );
    console.log(`Notification sent for new memory: ${description}`);
  } catch (error) {
    console.error(
      `Failed to send notification for new memory: ${description}`,
      error
    );
  }

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: newMemory._id,
      description: newMemory.description,
      image: newMemory.image,
      date: newMemory.date,
      time: newMemory.time,
      isFavorite: newMemory.isFavorite,
      createdAt: newMemory.createdAt,
      updatedAt: newMemory.updatedAt,
    },
  });
});

const getAllMemories = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

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

  const memories = await Memory.find({ childId }).sort({ date: -1 });

  // if (!memories.length) {
  //   return next(
  //     appError.create(
  //       "No memories found for this child",
  //       404,
  //       httpStatusText.FAIL
  //     )
  //   );
  // }

  res.json({
    status: httpStatusText.SUCCESS,
    data: memories.map((memory) => ({
      _id: memory._id,
      description: memory.description,
      image: memory.image,
      date: memory.date,
      time: memory.time,
      isFavorite: memory.isFavorite,
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
    })),
  });
});

const getSingleMemory = asyncWrapper(async (req, res, next) => {
  const { childId, memoryId } = req.params;
  const userId = req.user.id;

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

  const memory = await Memory.findOne({ _id: memoryId, childId });
  // if (!memory) {
  //   return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
  // }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: memory._id,
      description: memory.description,
      image: memory.image,
      date: memory.date,
      time: memory.time,
      isFavorite: memory.isFavorite,
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
    },
  });
});

const updateMemory = asyncWrapper(async (req, res, next) => {
  const { childId, memoryId } = req.params;
  const userId = req.user.id;
  const { description, date, time } = req.body;

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

  const memory = await Memory.findOne({ _id: memoryId, childId });
  // if (!memory) {
  //   return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
  // }

  const image = req.s3Data ? req.s3Data.url : memory.image;

  const updatedMemory = await Memory.findByIdAndUpdate(
    memoryId,
    { description, date, time, image },
    { new: true, runValidators: true }
  );

  try {
    await sendNotificationCore(
      userId,
      childId,
      null,
      "Memory Updated",
      `${child.name}: ${description || memory.description} updated.`,
      "memory",
      "patient"
    );
    console.log(
      `Notification sent for updated memory: ${
        description || memory.description
      }`
    );
  } catch (error) {
    console.error(
      `Failed to send notification for updated memory: ${
        description || memory.description
      }`,
      error
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: updatedMemory._id,
      description: updatedMemory.description,
      image: updatedMemory.image,
      date: updatedMemory.date,
      time: updatedMemory.time,
      isFavorite: updatedMemory.isFavorite,
      createdAt: updatedMemory.createdAt,
      updatedAt: updatedMemory.updatedAt,
    },
  });
});

const deleteMemory = asyncWrapper(async (req, res, next) => {
  const { childId, memoryId } = req.params;
  const userId = req.user.id;

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

  const memory = await Memory.findOneAndDelete({ _id: memoryId, childId });
  if (!memory) {
    return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
  }

  if (memory.image && memory.image !== "uploads/memory-default.jpg") {
    const key = memory.image.split("/").pop();
    await deleteObject(key);
  }

  try {
    await sendNotificationCore(
      userId,
      childId,
      null,
      "Memory Removed",
      `${child.name}: ${memory.description} removed.`,
      "memory",
      "patient"
    );
    console.log(`Notification sent for deleted memory: ${memory.description}`);
  } catch (error) {
    console.error(
      `Failed to send notification for deleted memory: ${memory.description}`,
      error
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Memory deleted successfully",
  });
});

const toggleFavoriteMemory = asyncWrapper(async (req, res, next) => {
  const { childId, memoryId } = req.params;
  const userId = req.user.id;

  console.log(
    "toggleFavoriteMemory started - childId:",
    childId,
    "memoryId:",
    memoryId
  );

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    console.log("Child not found or unauthorized for user:", userId);
    return next(
      appError.create(
        "Child not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const memory = await Memory.findOne({ _id: memoryId, childId });
  // if (!memory) {
  //   console.log("Memory not found for memoryId:", memoryId); // Log 3
  //   return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
  // }

  const newFavoriteValue = !memory.isFavorite;
  console.log(
    "Toggling isFavorite from",
    memory.isFavorite,
    "to",
    newFavoriteValue
  );

  const updatedMemory = await Memory.findByIdAndUpdate(
    memoryId,
    { isFavorite: newFavoriteValue },
    { new: true, runValidators: true }
  );

  if (!updatedMemory) {
    console.log("Failed to update memory with id:", memoryId);
    return next(
      appError.create("Failed to update memory", 500, httpStatusText.FAIL)
    );
  }

  console.log(
    "Memory updated successfully - new isFavorite:",
    updatedMemory.isFavorite
  );

  const notificationTitle = updatedMemory.isFavorite
    ? "Memory Favorited"
    : "Memory Unfavorited";
  const notificationMessage = updatedMemory.isFavorite
    ? `${child.name}: ${updatedMemory.description} added to favorites.`
    : `${child.name}: ${updatedMemory.description} removed from favorites.`;

  try {
    console.log(
      "Attempting to send notification for memory:",
      updatedMemory.description
    );
    await sendNotificationCore(
      userId,
      childId,
      null,
      notificationTitle,
      notificationMessage,
      "memory",
      "patient"
    );
    console.log("Notification sent successfully");
  } catch (error) {
    console.error("Failed to send notification:", error);
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: `Memory ${
      updatedMemory.isFavorite ? "added to" : "removed from"
    } favorites`,
    data: {
      _id: updatedMemory._id,
      isFavorite: updatedMemory.isFavorite,
    },
  });
});

const getFavoriteMemories = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

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

  const memories = await Memory.find({ childId, isFavorite: true }).select(
    "_id description image date time createdAt updatedAt"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    data: memories,
  });
});

module.exports = {
  createMemory,
  getAllMemories,
  getSingleMemory,
  updateMemory,
  deleteMemory,
  toggleFavoriteMemory,
  getFavoriteMemories,
};
