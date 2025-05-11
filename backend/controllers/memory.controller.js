// const Memory = require("../models/memory.model");
// const asyncWrapper = require("../middlewares/asyncWrapper");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");

// // ✅ create new memory
// const createMemory = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const { image, description, date, time } = req.body;

//   if (!image || !description || !date || !time) {
//     return next(
//       appError.create(
//         "All required fields must be provided",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const newMemory = new Memory({
//     childId,
//     image,
//     description,
//     date,
//     time,
//   });

//   await newMemory.save();

//       res.json({
//         status: httpStatusText.SUCCESS,
//         data: {
//           _id: newMemory._id,
//           image: newMemory.image,
//           description: newMemory.description,
//           date: newMemory.date,
//           time: newMemory.time,
//           isFavorite: newMemory.isFavorite,
//         },
//       });
// });

// // ✅ get all memories
// const getAllMemories = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;

//   const memories = await Memory.find({ childId }).sort({ createdAt: -1 });

//   if (!memories.length) {
//     return next(
//       appError.create(
//         "No memories found for this child",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }
//     res.json({
//       status: httpStatusText.SUCCESS,
//       data: memories.map((record) => ({
//         _id: record._id, // Child's ID
//         image: record.image,
//         description: record.description,
//         date: record.date,
//         time: record.time,
//         isFavorite: record.isFavorite,
//       })),
//     });
// });

// // ✅get all Favorite Memories
// const getFavoriteMemories = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;

//   const favoriteMemories = await Memory.find({
//     childId,
//     isFavorite: true,
//   }).sort({ createdAt: -1 });

//   if (!favoriteMemories.length) {
//     return next(
//       appError.create(
//         "No favorite memories found for this child",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }
//     res.json({
//       status: httpStatusText.SUCCESS,
//       data: favoriteMemories.map((record) => ({
//         _id: record._id, // Child's ID
//         image: record.image,
//         description: record.description,
//         date: record.date,
//         time: record.time,
//         isFavorite: record.isFavorite,
//       })),
//     });
// });

// // ✅ update memory to put favorite memory or none
// const toggleFavoriteMemory = asyncWrapper(async (req, res, next) => {
//   const { memoryId } = req.params;

//   const memory = await Memory.findById(memoryId);
//   if (!memory) {
//     return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
//   }

//   memory.isFavorite = !memory.isFavorite;
//   await memory.save();
//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       _id: memory._id,
//       image: memory.image,
//       description: memory.description,
//       date: memory.date,
//       time: memory.time,
//       isFavorite: memory.isFavorite,
//     },
//   });
// });

// // ✅ update memory
// const updateMemory = asyncWrapper(async (req, res, next) => {
//   const { memoryId } = req.params;
//   const { image, description, date, time } = req.body;

//   const memory = await Memory.findByIdAndUpdate(memoryId, {
//     image,
//     description,
//     date,
//     time,
//   }, { new: true });

//   if (!memory) {
//     return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
//   }

//   res.json({
//         status: httpStatusText.SUCCESS,
//         data: {
//           _id: memory._id,
//           image: memory.image,
//           description: memory.description,
//           date: memory.date,
//           time: memory.time,
//           isFavorite: memory.isFavorite,
//         },
//       });
// });

// // ✅ delete memory
// const deleteMemory = asyncWrapper(async (req, res, next) => {
//   const { memoryId } = req.params;

//   const deletedMemory = await Memory.findByIdAndDelete(memoryId);

//   if (!deletedMemory) {
//     return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Memory deleted successfully",
//   });
// });

// module.exports = {
//   createMemory,
//   getAllMemories,
//   getFavoriteMemories,
//   toggleFavoriteMemory,
//   updateMemory,
//   deleteMemory,
// };


const Memory = require("../models/memory.model");
const Child = require("../models/child.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const { sendNotification } = require("../controllers/notifications.controller");

const createMemory = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;
  const { title, description, date } = req.body;

  if (!title || !description || !date) {
    return next(
      appError.create(
        "Title, description, and date are required",
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

  const image = req.file ? `/uploads/${req.file.filename}` : null;

  const newMemory = new Memory({
    childId,
    title,
    description,
    image,
    date,
  });

  await newMemory.save();

  await sendNotification(
    userId,
    childId,
    null,
    "Memory Added",
    `${child.name}: ${title} added.`,
    "memory",
    "patient"
  );

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: newMemory._id,
      title: newMemory.title,
      description: newMemory.description,
      image: newMemory.image,
      date: newMemory.date,
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

  const memories = await Memory.find({ childId }).select(
    "_id title description image date createdAt updatedAt"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    data: memories,
  });
});

const updateMemory = asyncWrapper(async (req, res, next) => {
  const { childId, memoryId } = req.params;
  const userId = req.user.id;
  const { title, description, date } = req.body;

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
  if (!memory) {
    return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
  }

  const changes = [];
  if (title && title !== memory.title) {
    changes.push(`title to ${title}`);
    memory.title = title;
  }
  if (description && description !== memory.description) {
    changes.push(`description updated`);
    memory.description = description;
  }
  if (date && date !== memory.date.toISOString().split("T")[0]) {
    changes.push(`date to ${date}`);
    memory.date = date;
  }
  if (req.file) {
    changes.push(`image updated`);
    memory.image = `/uploads/${req.file.filename}`;
  }

  await memory.save();

  if (changes.length > 0) {
    await sendNotification(
      userId,
      childId,
      null,
      "Memory Updated",
      `${child.name}: ${changes.join(", ")}`,
      "memory",
      "patient"
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      _id: memory._id,
      title: memory.title,
      description: memory.description,
      image: memory.image,
      date: memory.date,
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
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

  const memory = await Memory.findOne({ _id: memoryId, childId });
  if (!memory) {
    return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
  }

  await Memory.deleteOne({ _id: memoryId });

  await sendNotification(
    userId,
    childId,
    null,
    "Memory Deleted",
    `${child.name}: ${memory.title} deleted.`,
    "memory",
    "patient"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Memory deleted successfully",
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

  const memories = await Memory.find({
    childId,
    _id: { $in: child.favorite },
  }).select("_id title description image date createdAt updatedAt");

  res.json({
    status: httpStatusText.SUCCESS,
    data: memories,
  });
});

const toggleFavoriteMemory = asyncWrapper(async (req, res, next) => {
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
  if (!memory) {
    return next(appError.create("Memory not found", 404, httpStatusText.FAIL));
  }

  const isMemoryInFavorites = child.favorite.includes(memoryId);
  let message, notificationTitle, notificationMessage;

  if (isMemoryInFavorites) {
    child.favorite = child.favorite.filter(
      (id) => id.toString() !== memoryId.toString()
    );
    message = "Memory removed from favorites successfully";
    notificationTitle = "Memory Unfavorited";
    notificationMessage = `${memory.title} removed from favorites.`;
  } else {
    child.favorite.push(memoryId);
    message = "Memory added to favorites successfully";
    notificationTitle = "Memory Favorited";
    notificationMessage = `${memory.title} added to favorites.`;
  }

  await child.save();

  await sendNotification(
    userId,
    childId,
    null,
    notificationTitle,
    notificationMessage,
    "memory",
    "patient"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    message: message,
  });
});

module.exports = {
  createMemory,
  getAllMemories,
  updateMemory,
  deleteMemory,
  getFavoriteMemories,
  toggleFavoriteMemory,
};