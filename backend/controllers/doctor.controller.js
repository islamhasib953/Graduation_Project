// const asyncWrapper = require("../middlewares/asyncWrapper");
// const Doctor = require("../models/doctor.model");
// const User = require("../models/user.model");
// const Child = require("../models/child.model");
// const Appointment = require("../models/appointment.model");
// const Growth = require("../models/growth.model");
// const History = require("../models/history.model");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");
// const { sendNotification } = require("./notifications.controller");
// const moment = require("moment");
// const mongoose = require("mongoose");

// // Get all doctors
// const getAllDoctors = asyncWrapper(async (req, res) => {
//   const doctors = await Doctor.find({}, { __v: false, password: false });
//   res.json({ status: httpStatusText.SUCCESS, data: { doctors } });
// });

// // Get a single doctor by ID
// const getSingleDoctor = asyncWrapper(async (req, res, next) => {
//   const doctorId = req.params.doctorId;

//   const doctor = await Doctor.findById(doctorId, {
//     __v: false,
//     password: false,
//   });

//   if (!doctor) {
//     const error = appError.create("Doctor not found", 404, httpStatusText.FAIL);
//     return next(error);
//   }

//   res.json({ status: httpStatusText.SUCCESS, data: { doctor } });
// });

// // Book an appointment
// const bookAppointment = asyncWrapper(async (req, res, next) => {
//   const { doctorId, childId } = req.params;
//   const { date, time, visitType } = req.body;
//   const userId = req.user.id;

//   if (req.user.role !== "patient") {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can book appointments",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   if (!date || !time || !visitType) {
//     return next(
//       appError.create(
//         "Date, time, and visitType are required",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const doctor = await Doctor.findById(doctorId);
//   if (!doctor) {
//     return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
//   }

//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const user = await User.findById(userId);
//   if (!user) {
//     return next(appError.create("User not found", 404, httpStatusText.FAIL));
//   }

//   // التأكد من تنسيق التاريخ والوقت
//   const appointmentDateTime = moment(
//     `${date} ${time}`,
//     "YYYY-MM-DD HH:mm"
//   ).toDate();
//   const now = new Date();
//   if (isNaN(appointmentDateTime) || appointmentDateTime <= now) {
//     return next(
//       appError.create(
//         "Appointment date and time must be in the future and in valid format (YYYY-MM-DD HH:mm)",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const existingAppointment = await Appointment.findOne({
//     doctorId,
//     date: date,
//     time: time,
//   });
//   if (existingAppointment) {
//     return next(
//       appError.create(
//         "This time slot is already booked",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const newAppointment = new Appointment({
//     userId,
//     childId,
//     doctorId,
//     date,
//     time,
//     visitType,
//   });

//   await newAppointment.save();

//   // إشعار فوري لليوزر (الطفل المستخدم حاليًا)
//   await sendNotification(
//     userId,
//     childId,
//     doctorId,
//     "Appointment Booked",
//     `You booked an appointment with Dr. ${doctor.firstName} ${doctor.lastName} on ${date} at ${time} (${visitType}).`,
//     "appointment",
//     "patient"
//   );

//   // إشعار فوري للدكتور
//   await sendNotification(
//     doctorId,
//     childId,
//     userId,
//     "New Appointment Booked",
//     `${child.name} booked an appointment with you on ${date} at ${time} (${visitType}).`,
//     "appointment",
//     "doctor"
//   );

//   res.status(201).json({
//     status: httpStatusText.SUCCESS,
//     data: { appointment: newAppointment },
//   });
// });

// // Reschedule an appointment
// const rescheduleAppointment = asyncWrapper(async (req, res, next) => {
//   const { appointmentId, childId } = req.params;
//   const { date, time } = req.body;
//   const userId = req.user.id;

//   if (req.user.role !== "patient") {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can reschedule appointments",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   if (!date || !time) {
//     return next(
//       appError.create("Date and time are required", 400, httpStatusText.FAIL)
//     );
//   }

//   const appointment = await Appointment.findOne({
//     _id: appointmentId,
//     childId,
//     userId,
//   }).populate("doctorId", "firstName lastName");
//   if (!appointment) {
//     return next(
//       appError.create(
//         "Appointment not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const appointmentDateTime = moment(
//     `${date} ${time}`,
//     "YYYY-MM-DD HH:mm"
//   ).toDate();
//   const now = new Date();
//   if (isNaN(appointmentDateTime) || appointmentDateTime <= now) {
//     return next(
//       appError.create(
//         "Appointment date and time must be in the future and in valid format (YYYY-MM-DD HH:mm)",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const existingAppointment = await Appointment.findOne({
//     doctorId: appointment.doctorId._id,
//     date,
//     time,
//     _id: { $ne: appointmentId },
//   });
//   if (existingAppointment) {
//     return next(
//       appError.create(
//         "This time slot is already booked",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const child = await Child.findById(childId);
//   if (!child) {
//     return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//   }

//   appointment.date = date;
//   appointment.time = time;
//   await appointment.save();

//   await sendNotification(
//     userId,
//     childId,
//     appointment.doctorId._id,
//     "Appointment Rescheduled",
//     `With Dr. ${appointment.doctorId.firstName} to ${date} at ${time}.`,
//     "appointment",
//     "patient"
//   );

//   await sendNotification(
//     appointment.doctorId._id,
//     childId,
//     userId,
//     "Appointment Rescheduled",
//     `${child.name} to ${date} at ${time}.`,
//     "appointment",
//     "doctor"
//   );

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: { appointment },
//   });
// });

// // Cancel an appointment
// const cancelAppointment = asyncWrapper(async (req, res, next) => {
//   const { appointmentId, childId } = req.params;
//   const userId = req.user.id;

//   if (req.user.role !== "patient") {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can cancel appointments",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const appointment = await Appointment.findOne({
//     _id: appointmentId,
//     childId,
//     userId,
//   }).populate("doctorId", "firstName lastName");
//   if (!appointment) {
//     return next(
//       appError.create(
//         "Appointment not found or you are not authorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const child = await Child.findById(childId);
//   if (!child) {
//     return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//   }

//   await Appointment.deleteOne({ _id: appointmentId });

//   await sendNotification(
//     userId,
//     childId,
//     appointment.doctorId._id,
//     "Appointment Cancelled",
//     `With Dr. ${appointment.doctorId.firstName} on ${appointment.date}.`,
//     "appointment",
//     "patient"
//   );

//   await sendNotification(
//     appointment.doctorId._id,
//     childId,
//     userId,
//     "Appointment Cancelled",
//     `${child.name} on ${appointment.date}.`,
//     "appointment",
//     "doctor"
//   );

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Appointment cancelled successfully",
//   });
// });

// // Toggle favorite doctor with childId in the path
// const toggleFavoriteDoctor = asyncWrapper(async (req, res, next) => {
//   const { childId, doctorId } = req.params;
//   const userId = req.user.id;

//   if (req.user.role !== "patient") {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can manage favorite doctors",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or not associated with this user",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const doctor = await Doctor.findById(doctorId);
//   if (!doctor) {
//     return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
//   }

//   const isDoctorInFavorites = child.favorite.includes(doctorId);
//   let message, notificationTitle, notificationMessage;

//   if (isDoctorInFavorites) {
//     child.favorite = child.favorite.filter(
//       (id) => id.toString() !== doctorId.toString()
//     );
//     message = "Doctor removed from favorites successfully";
//     notificationTitle = "Doctor Unfavorited";
//     notificationMessage = `Dr. ${doctor.firstName} removed from favorites.`;
//   } else {
//     child.favorite.push(doctorId);
//     message = "Doctor added to favorites successfully";
//     notificationTitle = "Doctor Favorited";
//     notificationMessage = `Dr. ${doctor.firstName} added to favorites.`;
//   }

//   await child.save();

//   await sendNotification(
//     userId,
//     childId,
//     doctorId,
//     notificationTitle,
//     notificationMessage,
//     "favorite",
//     "patient"
//   );

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: message,
//   });
// });

// // جلب الدكاترة المفضلين مع childId في الـ Path
// const getFavoriteDoctors = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;

//   if (req.user.role !== "patient") {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can view favorite doctors",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or not associated with this user",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const favoriteDoctorIds = child.favorite;
//   if (!favoriteDoctorIds || favoriteDoctorIds.length === 0) {
//     return next(
//       appError.create("No favorite doctors found", 404, httpStatusText.FAIL)
//     );
//   }

//   const doctors = await Doctor.find({
//     _id: { $in: favoriteDoctorIds },
//   }).select(
//     "firstName lastName phone availableTimes availableDays created_at address avatar specialise about rate"
//   );

//   if (!doctors.length) {
//     return next(
//       appError.create("No favorite doctors found", 404, httpStatusText.FAIL)
//     );
//   }

//   const currentDay = moment().format("dddd");
//   const today = moment().startOf("day").format("YYYY-MM-DD");

//   const doctorsWithStatus = await Promise.all(
//     doctors.map(async (doctor) => {
//       const hasAvailableDays =
//         doctor.availableDays && doctor.availableDays.length > 0;
//       const hasAvailableTimes =
//         doctor.availableTimes && doctor.availableTimes.length > 0;

//       if (!hasAvailableDays || !hasAvailableTimes) {
//         return {
//           _id: doctor._id,
//           firstName: doctor.firstName,
//           lastName: doctor.lastName,
//           phone: doctor.phone,
//           availableTimes: doctor.availableTimes,
//           availableDays: doctor.availableDays,
//           created_at: doctor.created_at,
//           address: doctor.address,
//           avatar: doctor.avatar,
//           specialise: doctor.specialise,
//           about: doctor.about,
//           rate: doctor.rate,
//           status: "Closed",
//           isFavorite: true,
//         };
//       }

//       const isDayAvailable = doctor.availableDays.includes(currentDay);
//       if (!isDayAvailable) {
//         return {
//           _id: doctor._id,
//           firstName: doctor.firstName,
//           lastName: doctor.lastName,
//           phone: doctor.phone,
//           availableTimes: doctor.availableTimes,
//           availableDays: doctor.availableDays,
//           created_at: doctor.created_at,
//           address: doctor.address,
//           avatar: doctor.avatar,
//           specialise: doctor.specialise,
//           about: doctor.about,
//           rate: doctor.rate,
//           status: "Closed",
//           isFavorite: true,
//         };
//       }

//       const bookedAppointments = await Appointment.find({
//         doctorId: doctor._id,
//         date: today,
//       }).select("time");

//       const bookedTimes = bookedAppointments.map(
//         (appointment) => appointment.time
//       );

//       const hasAvailableTimeToday = doctor.availableTimes.some(
//         (time) => !bookedTimes.includes(time)
//       );

//       const status = hasAvailableTimeToday ? "Open" : "Closed";

//       return {
//         _id: doctor._id,
//         firstName: doctor.firstName,
//         lastName: doctor.lastName,
//         phone: doctor.phone,
//         availableTimes: doctor.availableTimes,
//         availableDays: doctor.availableDays,
//         created_at: doctor.created_at,
//         address: doctor.address,
//         avatar: doctor.avatar,
//         specialise: doctor.specialise,
//         about: doctor.about,
//         rate: doctor.rate,
//         status,
//         isFavorite: true,
//       };
//     })
//   );

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: doctorsWithStatus,
//   });
// });

// // جلب بيانات الدكتور (Profile)
// const getDoctorProfile = asyncWrapper(async (req, res, next) => {
//   const doctorId = req.user.id;

//   if (!doctorId) {
//     return next(
//       appError.create("User ID not found in token", 401, httpStatusText.FAIL)
//     );
//   }

//   if (req.user.role !== "doctor") {
//     return next(
//       appError.create(
//         "Unauthorized: Only doctors can view their profile",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const doctor = await Doctor.findById(doctorId).select("-password -token");

//   if (!doctor) {
//     return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       firstName: doctor.firstName,
//       lastName: doctor.lastName,
//       gender: doctor.gender,
//       phone: doctor.phone,
//       address: doctor.address,
//       email: doctor.email,
//       role: doctor.role,
//       avatar: doctor.avatar,
//       specialise: doctor.specialise,
//       about: doctor.about,
//       rate: doctor.rate,
//       availableDays: doctor.availableDays,
//       availableTimes: doctor.availableTimes,
//       created_at: doctor.created_at,
//     },
//   });
// });

// // Update doctor profile
// const updateDoctorProfile = asyncWrapper(async (req, res, next) => {
//   const doctorId = req.user.id;
//   const {
//     firstName,
//     lastName,
//     email,
//     phone,
//     address,
//     specialise,
//     about,
//     rate,
//     availableDays,
//     availableTimes,
//   } = req.body;

//   if (req.user.role !== "doctor") {
//     return next(
//       appError.create(
//         "Unauthorized: Only doctors can update their profile",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const doctor = await Doctor.findById(doctorId);

//   if (!doctor) {
//     return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
//   }

//   const changes = [];
//   if (firstName && firstName !== doctor.firstName) {
//     changes.push(`name to ${firstName}`);
//     doctor.firstName = firstName;
//   }
//   if (lastName && lastName !== doctor.lastName) {
//     changes.push(`last name to ${lastName}`);
//     doctor.lastName = lastName;
//   }
//   if (email && email !== doctor.email) {
//     changes.push(`email to ${email}`);
//     doctor.email = email;
//   }
//   if (phone && phone !== doctor.phone) {
//     changes.push(`phone to ${phone}`);
//     doctor.phone = phone;
//   }
//   if (address && address !== doctor.address) {
//     changes.push(`address to ${address}`);
//     doctor.address = address;
//   }
//   if (specialise && specialise !== doctor.specialise) {
//     changes.push(`specialization to ${specialise}`);
//     doctor.specialise = specialise;
//   }
//   if (about && about !== doctor.about) {
//     changes.push(`about updated`);
//     doctor.about = about;
//   }
//   if (rate && rate !== doctor.rate) {
//     changes.push(`rate to ${rate}`);
//     doctor.rate = rate;
//   }
//   if (
//     availableDays &&
//     JSON.stringify(availableDays) !== JSON.stringify(doctor.availableDays)
//   ) {
//     changes.push(`available days updated`);
//     doctor.availableDays = availableDays;
//   }
//   if (
//     availableTimes &&
//     JSON.stringify(availableTimes) !== JSON.stringify(doctor.availableTimes)
//   ) {
//     changes.push(`available times updated`);
//     doctor.availableTimes = availableTimes;
//   }

//   await doctor.save();

//   // إشعار فوري للدكتور عند تعديل الملف الشخصي
//   if (changes.length > 0) {
//     await sendNotification(
//       doctorId,
//       null,
//       null,
//       "Profile Updated",
//       `Updated: ${changes.join(", ")}`,
//       "profile",
//       "doctor"
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Doctor profile updated successfully",
//     data: {
//       firstName: doctor.firstName,
//       lastName: doctor.lastName,
//       gender: doctor.gender,
//       phone: doctor.phone,
//       address: doctor.address,
//       email: doctor.email,
//       role: doctor.role,
//       specialise: doctor.specialise,
//       about: doctor.about,
//       rate: doctor.rate,
//       availableDays: doctor.availableDays,
//       availableTimes: doctor.availableTimes,
//       avatar: doctor.avatar,
//       created_at: doctor.created_at,
//     },
//   });
// });

// // Delete doctor profile
// const deleteDoctorProfile = asyncWrapper(async (req, res, next) => {
//   const doctorId = req.user.id;

//   if (req.user.role !== "doctor") {
//     return next(
//       appError.create(
//         "Unauthorized: Only doctors can delete their profile",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const doctor = await Doctor.findById(doctorId);
//   if (!doctor) {
//     return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
//   }

//   const session = await mongoose.startSession();
//   session.startTransaction();

//   try {
//     await Appointment.deleteMany({ doctorId }, { session });

//     doctor.token = null;
//     doctor.fcmToken = null;
//     await doctor.save({ session });

//     const deleteResult = await Doctor.deleteOne({ _id: doctorId }, { session });
//     if (deleteResult.deletedCount === 0) {
//       throw new Error("Failed to delete doctor account");
//     }

//     await User.updateMany(
//       { favorite: doctorId },
//       { $pull: { favorite: doctorId } },
//       { session }
//     );

//     await session.commitTransaction();

//     await sendNotification(
//       doctorId,
//       null,
//       null,
//       "Account Deleted",
//       "Your account has been deleted.",
//       "profile",
//       "doctor"
//     );

//     res.json({
//       status: httpStatusText.SUCCESS,
//       message: "Doctor account deleted successfully",
//     });
//   } catch (error) {
//     await session.abortTransaction();
//     return next(
//       appError.create(
//         error.message || "Failed to delete doctor account",
//         500,
//         httpStatusText.ERROR
//       )
//     );
//   } finally {
//     session.endSession();
//   }
// });

// // Logout doctor
// const logoutDoctor = asyncWrapper(async (req, res, next) => {
//   const doctorId = req.user.id;

//   if (req.user.role !== "doctor") {
//     return next(
//       appError.create(
//         "Unauthorized: Only doctors can logout",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const doctor = await Doctor.findById(doctorId);
//   if (!doctor) {
//     return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
//   }

//   doctor.token = null;
//   doctor.fcmToken = null;
//   await doctor.save();

//   await sendNotification(
//     doctorId,
//     null,
//     null,
//     "Logged Out",
//     "You have logged out.",
//     "general",
//     "doctor"
//   );

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Doctor logged out successfully",
//   });
// });

// // Update doctor availability
// const updateAvailability = asyncWrapper(async (req, res, next) => {
//   const doctorId = req.user.id;
//   const { availableDays, availableTimes } = req.body;

//   if (!availableDays || !availableTimes) {
//     return next(
//       appError.create(
//         "Available days and times are required",
//         400,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const doctor = await Doctor.findById(doctorId);
//   if (!doctor) {
//     return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
//   }

//   doctor.availableDays = availableDays;
//   doctor.availableTimes = availableTimes;
//   await doctor.save();

//   // إشعار فوري للدكتور
//   await sendNotification(
//     doctorId,
//     null,
//     null,
//     "Availability Updated",
//     "Your availability has been updated.",
//     "doctor",
//     "doctor"
//   );

//   // جلب جميع المواعيد المستقبلية للدكتور
//   const now = new Date();
//   const upcomingAppointments = await Appointment.find({
//     doctorId,
//     date: { $gte: now },
//     status: { $in: ["Pending", "Accepted"] },
//   })
//     .populate("childId", "name")
//     .populate("userId", "firstName lastName");

//   // إشعار فوري لجميع اليوزرز الذين لديهم مواعيد مستقبلية
//   for (const appointment of upcomingAppointments) {
//     if (!appointment.userId || !appointment.childId) continue; // تخطي إذا لم يكن هناك userId أو childId
//     const userId = appointment.userId._id;
//     const childId = appointment.childId._id;
//     const childName = appointment.childId.name;

//     await sendNotification(
//       userId,
//       childId,
//       doctorId,
//       "Doctor Availability Updated",
//       `Dr. ${doctor.firstName} ${doctor.lastName} updated their availability. Please check your upcoming appointment for ${childName} on ${appointment.date} at ${appointment.time}.`,
//       "appointment",
//       "patient"
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Availability updated successfully",
//     data: { availableDays, availableTimes },
//   });
// });

// // Get upcoming appointments
// const getUpcomingAppointments = asyncWrapper(async (req, res, next) => {
//   const doctorId = req.user.id;
//   const now = new Date();

//   if (req.user.role !== "doctor") {
//     return next(
//       appError.create(
//         "Unauthorized: Only doctors can view their appointments",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const appointments = await Appointment.find({
//     doctorId,
//     date: { $gte: now },
//   })
//     .populate("userId", "firstName lastName")
//     .populate("childId", "name");

//   if (!appointments.length) {
//     return next(
//       appError.create(
//         "No upcoming appointments found",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: appointments.map((appointment) => ({
//       _id: appointment._id,
//       user: {
//         firstName: appointment.userId?.firstName || "N/A",
//         lastName: appointment.userId?.lastName || "",
//       },
//       child: {
//         name: appointment.childId?.name || "N/A",
//       },
//       date: appointment.date,
//       time: appointment.time,
//       status: appointment.status,
//     })),
//   });
// });

// // Get child records (فقط النمو والتاريخ الطبي)
// const getChildRecords = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.body;
//   const doctorId = req.user.id;

//   if (req.user.role !== "doctor") {
//     return next(
//       appError.create(
//         "Unauthorized: Only doctors can view child records",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   if (!childId) {
//     return next(
//       appError.create("Child ID is required", 400, httpStatusText.FAIL)
//     );
//   }

//   const child = await Child.findById(childId);
//   if (!child) {
//     return next(appError.create("Child not found", 404, httpStatusText.FAIL));
//   }

//   const growthRecords = await Growth.find({ childId }).select(
//     "weight height headCircumference date time notes notesImage ageInMonths createdAt updatedAt"
//   );

//   const historyRecords = await History.find({ childId }).select(
//     "diagnosis disease treatment notes date time doctorName notesImage createdAt updatedAt"
//   );

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: {
//       growth: growthRecords,
//       history: historyRecords,
//     },
//   });
// });

// // Update appointment status
// const updateAppointmentStatus = asyncWrapper(async (req, res, next) => {
//   const { appointmentId } = req.params;
//   const { status } = req.body;
//   const doctorId = req.user.id;

//   if (!["Pending", "Accepted", "Closed"].includes(status)) {
//     return next(appError.create("Invalid status", 400, httpStatusText.FAIL));
//   }

//   if (req.user.role !== "doctor") {
//     return next(
//       appError.create(
//         "Unauthorized: Only doctors can update appointment status",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const appointment = await Appointment.findOne({
//     _id: appointmentId,
//     doctorId,
//   })
//     .populate("childId", "name")
//     .populate("doctorId", "firstName lastName")
//     .populate("userId", "firstName lastName");
//   if (!appointment) {
//     return next(
//       appError.create("Appointment not found", 404, httpStatusText.FAIL)
//     );
//   }

//   appointment.status = status;
//   await appointment.save();

//   // إشعار فوري لليوزر بناءً على حالة الحجز
//   await sendNotification(
//     appointment.userId._id,
//     appointment.childId._id,
//     doctorId,
//     "Appointment Status Updated",
//     `Dr. ${appointment.doctorId.firstName} ${
//       appointment.doctorId.lastName
//     } has ${status.toLowerCase()} your appointment for ${
//       appointment.childId.name
//     } on ${appointment.date} at ${appointment.time}.`,
//     "appointment",
//     "patient"
//   );

//   res.json({
//     status: httpStatusText.SUCCESS,
//     message: "Appointment status updated successfully",
//     data: appointment,
//   });
// });

// // Get user appointments
// const getUserAppointments = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;

//   if (req.user.role !== "patient") {
//     return next(
//       appError.create(
//         "Unauthorized: Only patients can view their appointments",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const appointments = await Appointment.find({ childId, userId })
//     .populate("doctorId", "firstName lastName")
//     .populate("childId", "name");

//   if (!appointments.length) {
//     return next(
//       appError.create("No appointments found", 404, httpStatusText.FAIL)
//     );
//   }

//   res.json({
//     status: httpStatusText.SUCCESS,
//     data: appointments.map((appointment) => ({
//       _id: appointment._id,
//       doctor: {
//         firstName: appointment.doctorId?.firstName || "N/A",
//         lastName: appointment.doctorId?.lastName || "",
//       },
//       child: {
//         name: appointment.childId?.name || "N/A",
//       },
//       date: appointment.date,
//       time: appointment.time,
//       status: appointment.status,
//     })),
//   });
// });

// // Save FCM Token
// const saveFcmToken = asyncWrapper(async (req, res, next) => {
//   const { fcmToken } = req.body;
//   const doctorId = req.user.id;

//   if (!fcmToken) {
//     return next(
//       appError.create("FCM Token is required", 400, httpStatusText.FAIL)
//     );
//   }

//   if (req.user.role !== "doctor") {
//     return next(
//       appError.create(
//         "Unauthorized: Only doctors can save FCM Token",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const doctor = await Doctor.findById(doctorId);
//   if (!doctor) {
//     return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
//   }

//   if (doctor.fcmToken === fcmToken) {
//     return res.status(200).json({
//       status: httpStatusText.SUCCESS,
//       message: "FCM Token is already up to date",
//     });
//   }

//   await Doctor.updateMany(
//     { fcmToken, _id: { $ne: doctorId } },
//     { fcmToken: null }
//   );

//   doctor.fcmToken = fcmToken;
//   await doctor.save();

//   await sendNotification(
//     doctorId,
//     null,
//     null,
//     "FCM Token Updated",
//     "Notification settings updated.",
//     "profile",
//     "doctor"
//   );

//   res.status(200).json({
//     status: httpStatusText.SUCCESS,
//     message: "FCM Token saved successfully",
//   });
// });

// module.exports = {
//   getAllDoctors,
//   getSingleDoctor,
//   bookAppointment,
//   rescheduleAppointment,
//   cancelAppointment,
//   toggleFavoriteDoctor,
//   getFavoriteDoctors,
//   getDoctorProfile,
//   updateDoctorProfile,
//   deleteDoctorProfile,
//   logoutDoctor,
//   updateAvailability,
//   getUpcomingAppointments,
//   getChildRecords,
//   updateAppointmentStatus,
//   getUserAppointments,
//   saveFcmToken,
// };

const asyncWrapper = require("../middlewares/asyncWrapper");
const Doctor = require("../models/doctor.model");
const User = require("../models/user.model");
const Child = require("../models/child.model");
const Appointment = require("../models/appointment.model");
const Growth = require("../models/growth.model");
const History = require("../models/history.model");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const { sendNotification } = require("./notifications.controller");
const moment = require("moment");
const mongoose = require("mongoose");

const getAllDoctors = asyncWrapper(async (req, res) => {
  const doctors = await Doctor.find({}, { __v: false, password: false });
  res.json({ status: httpStatusText.SUCCESS, data: { doctors } });
});

const getSingleDoctor = asyncWrapper(async (req, res, next) => {
  const doctorId = req.params.doctorId;

  const doctor = await Doctor.findById(doctorId, {
    __v: false,
    password: false,
  });

  if (!doctor) {
    const error = appError.create("Doctor not found", 404, httpStatusText.FAIL);
    return next(error);
  }

  res.json({ status: httpStatusText.SUCCESS, data: { doctor } });
});

const bookAppointment = asyncWrapper(async (req, res, next) => {
  const { doctorId, childId } = req.params;
  const { date, time, visitType } = req.body;
  const userId = req.user.id;

  if (req.user.role !== "patient") {
    return next(
      appError.create(
        "Unauthorized: Only patients can book appointments",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (!date || !time || !visitType) {
    return next(
      appError.create(
        "Date, time, and visitType are required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
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

  const user = await User.findById(userId);
  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  const appointmentDateTime = moment(
    `${date} ${time}`,
    "YYYY-MM-DD HH:mm"
  ).toDate();
  const now = new Date();
  if (isNaN(appointmentDateTime) || appointmentDateTime <= now) {
    return next(
      appError.create(
        "Appointment date and time must be in the future and in valid format (YYYY-MM-DD HH:mm)",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const existingAppointment = await Appointment.findOne({
    doctorId,
    date: date,
    time: time,
  });
  if (existingAppointment) {
    return next(
      appError.create(
        "This time slot is already booked",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const newAppointment = new Appointment({
    userId,
    childId,
    doctorId,
    date,
    time,
    visitType,
  });

  await newAppointment.save();

  await sendNotification(
    userId,
    childId,
    doctorId,
    "Appointment Booked",
    `You booked an appointment with Dr. ${doctor.firstName} ${doctor.lastName} on ${date} at ${time} (${visitType}).`,
    "appointment",
    "patient"
  );

  await sendNotification(
    doctorId,
    childId,
    userId,
    "New Appointment Booked",
    `${child.name} booked an appointment with you on ${date} at ${time} (${visitType}).`,
    "appointment",
    "doctor"
  );

  res.status(201).json({
    status: httpStatusText.SUCCESS,
    data: { appointment: newAppointment },
  });
});

const rescheduleAppointment = asyncWrapper(async (req, res, next) => {
  const { appointmentId, childId } = req.params;
  const { date, time } = req.body;
  const userId = req.user.id;

  if (req.user.role !== "patient") {
    return next(
      appError.create(
        "Unauthorized: Only patients can reschedule appointments",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (!date || !time) {
    return next(
      appError.create("Date and time are required", 400, httpStatusText.FAIL)
    );
  }

  const appointment = await Appointment.findOne({
    _id: appointmentId,
    childId,
    userId,
  }).populate("doctorId", "firstName lastName");
  if (!appointment) {
    return next(
      appError.create(
        "Appointment not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const appointmentDateTime = moment(
    `${date} ${time}`,
    "YYYY-MM-DD HH:mm"
  ).toDate();
  const now = new Date();
  if (isNaN(appointmentDateTime) || appointmentDateTime <= now) {
    return next(
      appError.create(
        "Appointment date and time must be in the future and in valid format (YYYY-MM-DD HH:mm)",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const existingAppointment = await Appointment.findOne({
    doctorId: appointment.doctorId._id,
    date,
    time,
    _id: { $ne: appointmentId },
  });
  if (existingAppointment) {
    return next(
      appError.create(
        "This time slot is already booked",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  appointment.date = date;
  appointment.time = time;
  await appointment.save();

  await sendNotification(
    userId,
    childId,
    appointment.doctorId._id,
    "Appointment Rescheduled",
    `With Dr. ${appointment.doctorId.firstName} to ${date} at ${time}.`,
    "appointment",
    "patient"
  );

  await sendNotification(
    appointment.doctorId._id,
    childId,
    userId,
    "Appointment Rescheduled",
    `${child.name} to ${date} at ${time}.`,
    "appointment",
    "doctor"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    data: { appointment },
  });
});

const cancelAppointment = asyncWrapper(async (req, res, next) => {
  const { appointmentId, childId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== "patient") {
    return next(
      appError.create(
        "Unauthorized: Only patients can cancel appointments",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const appointment = await Appointment.findOne({
    _id: appointmentId,
    childId,
    userId,
  }).populate("doctorId", "firstName lastName");
  if (!appointment) {
    return next(
      appError.create(
        "Appointment not found or you are not authorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  await Appointment.deleteOne({ _id: appointmentId });

  await sendNotification(
    userId,
    childId,
    appointment.doctorId._id,
    "Appointment Cancelled",
    `With Dr. ${appointment.doctorId.firstName} on ${appointment.date}.`,
    "appointment",
    "patient"
  );

  await sendNotification(
    appointment.doctorId._id,
    childId,
    userId,
    "Appointment Cancelled",
    `${child.name} on ${appointment.date}.`,
    "appointment",
    "doctor"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Appointment cancelled successfully",
  });
});

const toggleFavoriteDoctor = asyncWrapper(async (req, res, next) => {
  const { childId, doctorId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== "patient") {
    return next(
      appError.create(
        "Unauthorized: Only patients can manage favorite doctors",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or not associated with this user",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const isDoctorInFavorites = child.favorite.includes(doctorId);
  let message, notificationTitle, notificationMessage;

  if (isDoctorInFavorites) {
    child.favorite = child.favorite.filter(
      (id) => id.toString() !== doctorId.toString()
    );
    message = "Doctor removed from favorites successfully";
    notificationTitle = "Doctor Unfavorited";
    notificationMessage = `Dr. ${doctor.firstName} removed from favorites.`;
  } else {
    child.favorite.push(doctorId);
    message = "Doctor added to favorites successfully";
    notificationTitle = "Doctor Favorited";
    notificationMessage = `Dr. ${doctor.firstName} added to favorites.`;
  }

  await child.save();

  await sendNotification(
    userId,
    childId,
    doctorId,
    notificationTitle,
    notificationMessage,
    "favorite",
    "patient"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    message: message,
  });
});

const getFavoriteDoctors = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== "patient") {
    return next(
      appError.create(
        "Unauthorized: Only patients can view favorite doctors",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or not associated with this user",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const favoriteDoctorIds = child.favorite;
  if (!favoriteDoctorIds || favoriteDoctorIds.length === 0) {
    return next(
      appError.create("No favorite doctors found", 404, httpStatusText.FAIL)
    );
  }

  const doctors = await Doctor.find({
    _id: { $in: favoriteDoctorIds },
  }).select(
    "firstName lastName phone availableTimes availableDays created_at address avatar specialise about rate"
  );

  if (!doctors.length) {
    return next(
      appError.create("No favorite doctors found", 404, httpStatusText.FAIL)
    );
  }

  const currentDay = moment().format("dddd");
  const today = moment().startOf("day").format("YYYY-MM-DD");

  const doctorsWithStatus = await Promise.all(
    doctors.map(async (doctor) => {
      const hasAvailableDays =
        doctor.availableDays && doctor.availableDays.length > 0;
      const hasAvailableTimes =
        doctor.availableTimes && doctor.availableTimes.length > 0;

      if (!hasAvailableDays || !hasAvailableTimes) {
        return {
          _id: doctor._id,
          firstName: doctor.firstName,
          lastName: doctor.lastName,
          phone: doctor.phone,
          availableTimes: doctor.availableTimes,
          availableDays: doctor.availableDays,
          created_at: doctor.created_at,
          address: doctor.address,
          avatar: doctor.avatar,
          specialise: doctor.specialise,
          about: doctor.about,
          rate: doctor.rate,
          status: "Closed",
          isFavorite: true,
        };
      }

      const isDayAvailable = doctor.availableDays.includes(currentDay);
      if (!isDayAvailable) {
        return {
          _id: doctor._id,
          firstName: doctor.firstName,
          lastName: doctor.lastName,
          phone: doctor.phone,
          availableTimes: doctor.availableTimes,
          availableDays: doctor.availableDays,
          created_at: doctor.created_at,
          address: doctor.address,
          avatar: doctor.avatar,
          specialise: doctor.specialise,
          about: doctor.about,
          rate: doctor.rate,
          status: "Closed",
          isFavorite: true,
        };
      }

      const bookedAppointments = await Appointment.find({
        doctorId: doctor._id,
        date: today,
      }).select("time");

      const bookedTimes = bookedAppointments.map(
        (appointment) => appointment.time
      );

      const hasAvailableTimeToday = doctor.availableTimes.some(
        (time) => !bookedTimes.includes(time)
      );

      const status = hasAvailableTimeToday ? "Open" : "Closed";

      return {
        _id: doctor._id,
        firstName: doctor.firstName,
        lastName: doctor.lastName,
        phone: doctor.phone,
        availableTimes: doctor.availableTimes,
        availableDays: doctor.availableDays,
        created_at: doctor.created_at,
        address: doctor.address,
        avatar: doctor.avatar,
        specialise: doctor.specialise,
        about: doctor.about,
        rate: doctor.rate,
        status,
        isFavorite: true,
      };
    })
  );

  res.json({
    status: httpStatusText.SUCCESS,
    data: doctorsWithStatus,
  });
});

const getDoctorProfile = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

  if (!doctorId) {
    return next(
      appError.create("User ID not found in token", 401, httpStatusText.FAIL)
    );
  }

  if (req.user.role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only doctors can view their profile",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId).select("-password -token");

  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      firstName: doctor.firstName,
      lastName: doctor.lastName,
      gender: doctor.gender,
      phone: doctor.phone,
      address: doctor.address,
      email: doctor.email,
      role: doctor.role,
      avatar: doctor.avatar,
      specialise: doctor.specialise,
      about: doctor.about,
      rate: doctor.rate,
      availableDays: doctor.availableDays,
      availableTimes: doctor.availableTimes,
      created_at: doctor.created_at,
    },
  });
});

const updateDoctorProfile = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;
  const {
    firstName,
    lastName,
    email,
    phone,
    address,
    specialise,
    about,
    rate,
    availableDays,
    availableTimes,
  } = req.body;

  if (req.user.role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only doctors can update their profile",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);

  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const changes = [];
  if (firstName && firstName !== doctor.firstName) {
    changes.push(`name to ${firstName}`);
    doctor.firstName = firstName;
  }
  if (lastName && lastName !== doctor.lastName) {
    changes.push(`last name to ${lastName}`);
    doctor.lastName = lastName;
  }
  if (email && email !== doctor.email) {
    changes.push(`email to ${email}`);
    doctor.email = email;
  }
  if (phone && phone !== doctor.phone) {
    changes.push(`phone to ${phone}`);
    doctor.phone = phone;
  }
  if (address && address !== doctor.address) {
    changes.push(`address to ${address}`);
    doctor.address = address;
  }
  if (specialise && specialise !== doctor.specialise) {
    changes.push(`specialization to ${specialise}`);
    doctor.specialise = specialise;
  }
  if (about && about !== doctor.about) {
    changes.push(`about updated`);
    doctor.about = about;
  }
  if (rate && rate !== doctor.rate) {
    changes.push(`rate to ${rate}`);
    doctor.rate = rate;
  }
  if (
    availableDays &&
    JSON.stringify(availableDays) !== JSON.stringify(doctor.availableDays)
  ) {
    changes.push(`available days updated`);
    doctor.availableDays = availableDays;
  }
  if (
    availableTimes &&
    JSON.stringify(availableTimes) !== JSON.stringify(doctor.availableTimes)
  ) {
    changes.push(`available times updated`);
    doctor.availableTimes = availableTimes;
  }
  if (req.file) {
    changes.push(`avatar updated`);
    doctor.avatar = `/uploads/${req.file.filename}`;
  }

  await doctor.save();

  if (changes.length > 0) {
    await sendNotification(
      doctorId,
      null,
      null,
      "Profile Updated",
      `Updated: ${changes.join(", ")}`,
      "profile",
      "doctor"
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Doctor profile updated successfully",
    data: {
      firstName: doctor.firstName,
      lastName: doctor.lastName,
      gender: doctor.gender,
      phone: doctor.phone,
      address: doctor.address,
      email: doctor.email,
      role: doctor.role,
      specialise: doctor.specialise,
      about: doctor.about,
      rate: doctor.rate,
      availableDays: doctor.availableDays,
      availableTimes: doctor.availableTimes,
      avatar: doctor.avatar,
      created_at: doctor.created_at,
    },
  });
});

const deleteDoctorProfile = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

  if (req.user.role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only doctors can delete their profile",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    await Appointment.deleteMany({ doctorId }, { session });

    doctor.token = null;
    doctor.fcmToken = null;
    await doctor.save({ session });

    const deleteResult = await Doctor.deleteOne({ _id: doctorId }, { session });
    if (deleteResult.deletedCount === 0) {
      throw new Error("Failed to delete doctor account");
    }

    await User.updateMany(
      { favorite: doctorId },
      { $pull: { favorite: doctorId } },
      { session }
    );

    await session.commitTransaction();

    await sendNotification(
      doctorId,
      null,
      null,
      "Account Deleted",
      "Your account has been deleted.",
      "profile",
      "doctor"
    );

    res.json({
      status: httpStatusText.SUCCESS,
      message: "Doctor account deleted successfully",
    });
  } catch (error) {
    await session.abortTransaction();
    return next(
      appError.create(
        error.message || "Failed to delete doctor account",
        500,
        httpStatusText.ERROR
      )
    );
  } finally {
    session.endSession();
  }
});

const logoutDoctor = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

  if (req.user.role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only doctors can logout",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  doctor.token = null;
  doctor.fcmToken = null;
  await doctor.save();

  await sendNotification(
    doctorId,
    null,
    null,
    "Logged Out",
    "You have logged out.",
    "general",
    "doctor"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Doctor logged out successfully",
  });
});

const updateAvailability = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;
  const { availableDays, availableTimes } = req.body;

  if (!availableDays || !availableTimes) {
    return next(
      appError.create(
        "Available days and times are required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  doctor.availableDays = availableDays;
  doctor.availableTimes = availableTimes;
  await doctor.save();

  await sendNotification(
    doctorId,
    null,
    null,
    "Availability Updated",
    "Your availability has been updated.",
    "doctor",
    "doctor"
  );

  const now = new Date();
  const upcomingAppointments = await Appointment.find({
    doctorId,
    date: { $gte: now },
    status: { $in: ["Pending", "Accepted"] },
  })
    .populate("childId", "name")
    .populate("userId", "firstName lastName");

  for (const appointment of upcomingAppointments) {
    if (!appointment.userId || !appointment.childId) continue;
    const userId = appointment.userId._id;
    const childId = appointment.childId._id;
    const childName = appointment.childId.name;

    await sendNotification(
      userId,
      childId,
      doctorId,
      "Doctor Availability Updated",
      `Dr. ${doctor.firstName} ${doctor.lastName} updated their availability. Please check your upcoming appointment for ${childName} on ${appointment.date} at ${appointment.time}.`,
      "appointment",
      "patient"
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Availability updated successfully",
    data: { availableDays, availableTimes },
  });
});

const getUpcomingAppointments = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;
  const now = new Date();

  if (req.user.role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only doctors can view their appointments",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const appointments = await Appointment.find({
    doctorId,
    date: { $gte: now },
  })
    .populate("userId", "firstName lastName")
    .populate("childId", "name");

  if (!appointments.length) {
    return next(
      appError.create(
        "No upcoming appointments found",
        404,
        httpStatusText.FAIL
      )
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: appointments.map((appointment) => ({
      _id: appointment._id,
      user: {
        firstName: appointment.userId?.firstName || "N/A",
        lastName: appointment.userId?.lastName || "",
      },
      child: {
        name: appointment.childId?.name || "N/A",
      },
      date: appointment.date,
      time: appointment.time,
      status: appointment.status,
    })),
  });
});

const getChildRecords = asyncWrapper(async (req, res, next) => {
  const { childId } = req.body;
  const doctorId = req.user.id;

  if (req.user.role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only doctors can view child records",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (!childId) {
    return next(
      appError.create("Child ID is required", 400, httpStatusText.FAIL)
    );
  }

  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const growthRecords = await Growth.find({ childId }).select(
    "weight height headCircumference date time notes notesImage ageInMonths createdAt updatedAt"
  );

  const historyRecords = await History.find({ childId }).select(
    "diagnosis disease treatment notes date time doctorName notesImage createdAt updatedAt"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      growth: growthRecords,
      history: historyRecords,
    },
  });
});

const updateAppointmentStatus = asyncWrapper(async (req, res, next) => {
  const { appointmentId } = req.params;
  const { status } = req.body;
  const doctorId = req.user.id;

  if (!["Pending", "Accepted", "Closed"].includes(status)) {
    return next(appError.create("Invalid status", 400, httpStatusText.FAIL));
  }

  if (req.user.role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only doctors can update appointment status",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const appointment = await Appointment.findOne({
    _id: appointmentId,
    doctorId,
  })
    .populate("childId", "name")
    .populate("doctorId", "firstName lastName")
    .populate("userId", "firstName lastName");
  if (!appointment) {
    return next(
      appError.create("Appointment not found", 404, httpStatusText.FAIL)
    );
  }

  appointment.status = status;
  await appointment.save();

  await sendNotification(
    appointment.userId._id,
    appointment.childId._id,
    doctorId,
    "Appointment Status Updated",
    `Dr. ${appointment.doctorId.firstName} ${
      appointment.doctorId.lastName
    } has ${status.toLowerCase()} your appointment for ${
      appointment.childId.name
    } on ${appointment.date} at ${appointment.time}.`,
    "appointment",
    "patient"
  );

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Appointment status updated successfully",
    data: appointment,
  });
});

const getUserAppointments = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== "patient") {
    return next(
      appError.create(
        "Unauthorized: Only patients can view their appointments",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const appointments = await Appointment.find({ childId, userId })
    .populate("doctorId", "firstName lastName")
    .populate("childId", "name");

  if (!appointments.length) {
    return next(
      appError.create("No appointments found", 404, httpStatusText.FAIL)
    );
  }

  res.json({
    status: httpStatusText.SUCCESS,
    data: appointments.map((appointment) => ({
      _id: appointment._id,
      doctor: {
        firstName: appointment.doctorId?.firstName || "N/A",
        lastName: appointment.doctorId?.lastName || "",
      },
      child: {
        name: appointment.childId?.name || "N/A",
      },
      date: appointment.date,
      time: appointment.time,
      status: appointment.status,
    })),
  });
});

const saveFcmToken = asyncWrapper(async (req, res, next) => {
  const { fcmToken } = req.body;
  const doctorId = req.user.id;

  if (!fcmToken) {
    return next(
      appError.create("FCM Token is required", 400, httpStatusText.FAIL)
    );
  }

  if (req.user.role !== "doctor") {
    return next(
      appError.create(
        "Unauthorized: Only doctors can save FCM Token",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  if (doctor.fcmToken === fcmToken) {
    return res.status(200).json({
      status: httpStatusText.SUCCESS,
      message: "FCM Token is already up to date",
    });
  }

  await Doctor.updateMany(
    { fcmToken, _id: { $ne: doctorId } },
    { fcmToken: null }
  );

  doctor.fcmToken = fcmToken;
  await doctor.save();

  await sendNotification(
    doctorId,
    null,
    null,
    "FCM Token Updated",
    "Notification settings updated.",
    "profile",
    "doctor"
  );

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    message: "FCM Token saved successfully",
  });
});

module.exports = {
  getAllDoctors,
  getSingleDoctor,
  bookAppointment,
  rescheduleAppointment,
  cancelAppointment,
  toggleFavoriteDoctor,
  getFavoriteDoctors,
  getDoctorProfile,
  updateDoctorProfile,
  deleteDoctorProfile,
  logoutDoctor,
  updateAvailability,
  getUpcomingAppointments,
  getChildRecords,
  updateAppointmentStatus,
  getUserAppointments,
  saveFcmToken,
};