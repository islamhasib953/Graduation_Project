const Doctor = require("../models/doctor.model");
const User = require("../models/user.model");
const Appointment = require("../models/appointment.model");
const Child = require("../models/child.model");
const History = require("../models/history.model");
const Growth = require("../models/growth.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const userRoles = require("../utils/userRoles");
const moment = require("moment");
const mongoose = require("mongoose");

// ✅ عرض كل الدكاترة (مع childId في الـ Path)
const getAllDoctors = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  // التحقق من إن الـ childId مرتبط باليوزر
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

  const doctors = await Doctor.find().select(
    "firstName lastName phone availableTimes availableDays created_at address avatar specialise about rate"
  );

  if (!doctors.length) {
    return next(appError.create("No doctors found", 404, httpStatusText.FAIL));
  }

  const currentDay = moment().format("dddd");
  const today = moment().startOf("day").toDate();

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
          isFavorite: child.favorite.includes(doctor._id),
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
          isFavorite: child.favorite.includes(doctor._id),
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
        isFavorite: child.favorite.includes(doctor._id),
      };
    })
  );

  res.json({
    status: httpStatusText.SUCCESS,
    data: doctorsWithStatus,
  });
});

// ✅ عرض تفاصيل دكتور معين (مع childId في الـ Path)
const getSingleDoctor = asyncWrapper(async (req, res, next) => {
  const { doctorId, childId } = req.params;
  const userId = req.user.id;

  if (
    !req.user ||
    ![userRoles.PATIENT, userRoles.DOCTOR].includes(req.user.role)
  ) {
    return next(
      appError.create(
        "Unauthorized: Only patients or doctors can view doctor details",
        403,
        httpStatusText.FAIL
      )
    );
  }

  // التحقق من إن الـ childId مرتبط باليوزر (إذا كان المستخدم ليس دكتور)
  if (req.user.role !== userRoles.DOCTOR) {
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
  }

  const doctor = await Doctor.findById(doctorId).select(
    "firstName lastName phone availableTimes availableDays created_at address avatar specialise about rate"
  );

  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const currentDay = moment().format("dddd");
  const today = moment().startOf("day").toDate();

  const hasAvailableDays =
    doctor.availableDays && doctor.availableDays.length > 0;
  const hasAvailableTimes =
    doctor.availableTimes && doctor.availableTimes.length > 0;

  let status = "Closed";

  if (hasAvailableDays && hasAvailableTimes) {
    const isDayAvailable = doctor.availableDays.includes(currentDay);
    if (isDayAvailable) {
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

      if (hasAvailableTimeToday) {
        status = "Open";
      }
    }
  }

  const bookedAppointments = await Appointment.find({
    doctorId,
    childId,
  }).select("date time");

  const child = await Child.findById(childId);

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
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
      bookedAppointments: bookedAppointments.map((appointment) => ({
        date: appointment.date,
        time: appointment.time,
      })),
      isFavorite: child ? child.favorite.includes(doctor._id) : false,
    },
  });
});

// ✅ حجز موعد مع دكتور (مع childId في الـ Path)
const bookAppointment = asyncWrapper(async (req, res, next) => {
  const { doctorId, childId } = req.params;
  const { date, time, visitType } = req.body;
  const userId = req.user.id;

  if (!date || !time || !visitType) {
    return next(
      appError.create(
        "Date, time, and visit type are required",
        400,
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

  const appointmentDate = moment(date);
  if (appointmentDate.isBefore(moment(), "day")) {
    return next(
      appError.create(
        "Cannot book an appointment in the past",
        400,
        httpStatusText.FAIL
      )
    );
  }

  if (!/^(1[0-2]|0?[1-9]):([0-5][0-9]) (AM|PM)$/i.test(time)) {
    return next(
      appError.create(
        "Time must be in the format HH:MM AM/PM (e.g., 9:00 AM)",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const hasAvailableDays =
    doctor.availableDays && doctor.availableDays.length > 0;
  const hasAvailableTimes =
    doctor.availableTimes && doctor.availableTimes.length > 0;
  if (!hasAvailableDays || !hasAvailableTimes) {
    return next(
      appError.create(
        "Doctor is not available for booking",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const requestedDay = moment(date).format("dddd");
  const normalizedTime = time.trim().toUpperCase();
  const isDayAvailable = doctor.availableDays.includes(requestedDay);
  const isTimeAvailable = doctor.availableTimes.includes(normalizedTime);

  if (!isDayAvailable || !isTimeAvailable) {
    return next(
      appError.create(
        "Doctor is not available at this date or time",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const existingAppointment = await Appointment.findOne({
    doctorId,
    date: moment(date).startOf("day").toDate(),
    time: normalizedTime,
  });

  if (existingAppointment) {
    return next(
      appError.create(
        "This exact appointment (date and time) is already booked",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const newAppointment = new Appointment({
    userId,
    doctorId,
    childId,
    date: moment(date).startOf("day").toDate(),
    time: normalizedTime,
    visitType,
  });

  await newAppointment.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Appointment booked successfully",
    data: {
      appointmentId: newAppointment._id,
      doctorId: doctor._id,
      childId: newAppointment.childId,
      date: moment(newAppointment.date).format("YYYY-MM-DD"),
      time: newAppointment.time,
      visitType,
    },
  });
});

// ✅ جلب كل الحجوزات بتاعة اليوزر (مع childId في الـ Path)
const getUserAppointments = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can view their appointments",
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

  const appointments = await Appointment.find({ userId, childId })
    .populate("doctorId", "firstName lastName avatar address")
    .populate("childId", "name")
    .select("doctorId childId date time visitType status created_at");

  if (!appointments.length) {
    return next(
      appError.create("No appointments found", 404, httpStatusText.FAIL)
    );
  }

  const sortedAppointments = appointments.sort(
    (a, b) => new Date(a.date) - new Date(b.date)
  );

  const groupedAppointments = sortedAppointments.reduce((acc, appointment) => {
    const date = new Date(appointment.date);
    const monthYear = `${date.toLocaleString("default", {
      month: "short",
    })} ${date.getFullYear()}`;

    if (!acc[monthYear]) {
      acc[monthYear] = [];
    }

    acc[monthYear].push({
      appointmentId: appointment._id,
      childId: appointment.childId._id,
      childName: appointment.childId.name,
      doctorId: appointment.doctorId._id,
      doctorName: `${appointment.doctorId.firstName} ${appointment.doctorId.lastName}`,
      doctorAvatar: appointment.doctorId.avatar,
      doctorAddress: appointment.doctorId.address,
      date: appointment.date,
      time: appointment.time,
      visitType: appointment.visitType,
      status: appointment.status,
    });

    return acc;
  }, {});

  res.json({
    status: httpStatusText.SUCCESS,
    data: groupedAppointments,
  });
});

// ✅ تحديث حالة الحجز (Accept أو Close)
const updateAppointmentStatus = asyncWrapper(async (req, res, next) => {
  const { appointmentId } = req.params;
  const { status } = req.body;
  const doctorId = req.user.id;

  if (req.user.role !== userRoles.DOCTOR) {
    return next(
      appError.create(
        "Unauthorized: Only doctors can update appointment status",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (!status || !["Accepted", "Closed"].includes(status)) {
    return next(
      appError.create(
        "Status must be either 'Accepted' or 'Closed'",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const appointment = await Appointment.findById(appointmentId);

  if (!appointment) {
    return next(
      appError.create("Appointment not found", 404, httpStatusText.FAIL)
    );
  }

  if (appointment.doctorId.toString() !== doctorId.toString()) {
    return next(
      appError.create(
        "You are not authorized to update this appointment",
        403,
        httpStatusText.FAIL
      )
    );
  }

  appointment.status = status;
  await appointment.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Appointment status updated successfully",
    data: {
      appointmentId: appointment._id,
      status: appointment.status,
    },
  });
});

// ✅ جلب الدكاترة المفضلين مع childId في الـ Path
const getFavoriteDoctors = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can view favorite doctors",
        403,
        httpStatusText.FAIL
      )
    );
  }

  // التحقق من إن الـ childId مرتبط باليوزر
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

  // جلب الدكاترة الموجودين في قائمة favorite بتاعة الطفل
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
  const today = moment().startOf("day").toDate();

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

// ✅ تعديل موعد الحجز (Reschedule) (مع childId في الـ Path)
const rescheduleAppointment = asyncWrapper(async (req, res, next) => {
  const { appointmentId, childId } = req.params;
  const { date, time } = req.body;
  const userId = req.user.id;

  if (!date || !time) {
    return next(
      appError.create("Date and time are required", 400, httpStatusText.FAIL)
    );
  }

  const newDate = moment(date);
  if (newDate.isBefore(moment(), "day")) {
    return next(
      appError.create(
        "Cannot reschedule to a past date",
        400,
        httpStatusText.FAIL
      )
    );
  }

  if (!/^(1[0-2]|0?[1-9]):([0-5][0-9]) (AM|PM)$/i.test(time)) {
    return next(
      appError.create(
        "Time must be in the format HH:MM AM/PM (e.g., 9:00 AM)",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const appointment = await Appointment.findById(appointmentId);

  if (!appointment) {
    return next(
      appError.create("Appointment not found", 404, httpStatusText.FAIL)
    );
  }

  if (appointment.userId.toString() !== userId.toString()) {
    return next(
      appError.create(
        "You are not authorized to reschedule this appointment",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (appointment.childId.toString() !== childId) {
    return next(
      appError.create(
        "This appointment does not belong to the specified child",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (appointment.status === "Accepted") {
    return next(
      appError.create(
        "Cannot reschedule an accepted appointment. You can only cancel it.",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(appointment.doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const requestedDay = newDate.format("dddd");
  const isDayAvailable = doctor.availableDays.includes(requestedDay);
  const isTimeAvailable = doctor.availableTimes.includes(time);

  if (!isDayAvailable || !isTimeAvailable) {
    return next(
      appError.create(
        "Doctor is not available at this new date or time",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const existingAppointment = await Appointment.findOne({
    doctorId: appointment.doctorId,
    date: newDate.startOf("day").toDate(),
    time,
    _id: { $ne: appointmentId },
  });

  if (existingAppointment) {
    return next(
      appError.create(
        "This exact new time slot (date and time) is already booked",
        400,
        httpStatusText.FAIL
      )
    );
  }

  appointment.date = newDate.startOf("day").toDate();
  appointment.time = time;
  await appointment.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Appointment rescheduled successfully",
    data: {
      appointmentId: appointment._id,
      childId: appointment.childId,
      date: appointment.date,
      time: appointment.time,
    },
  });
});

// ✅ إلغاء الحجز (مع childId في الـ Path)
const deleteAppointment = asyncWrapper(async (req, res, next) => {
  const { appointmentId, childId } = req.params;
  const userId = req.user.id;

  const appointment = await Appointment.findById(appointmentId);

  if (!appointment) {
    return next(
      appError.create("Appointment not found", 404, httpStatusText.FAIL)
    );
  }

  if (appointment.userId.toString() !== userId.toString()) {
    return next(
      appError.create(
        "You are not authorized to delete this appointment",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (appointment.childId.toString() !== childId) {
    return next(
      appError.create(
        "This appointment does not belong to the specified child",
        403,
        httpStatusText.FAIL
      )
    );
  }

  await Appointment.deleteOne({ _id: appointmentId });

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Appointment deleted successfully",
  });
});

// ✅ جلب كل الحجوزات القادمة للدكتور
const getUpcomingAppointments = asyncWrapper(async (req, res, next) => {
  if (!req.user || !req.user.id) {
    return next(
      appError.create(
        "Unauthorized: User ID not found in token",
        401,
        httpStatusText.FAIL
      )
    );
  }

  const doctorId = req.user.id;

  if (!mongoose.Types.ObjectId.isValid(doctorId)) {
    return next(
      appError.create("Invalid Doctor ID in token", 400, httpStatusText.FAIL)
    );
  }

  if (req.user.role !== userRoles.DOCTOR) {
    return next(
      appError.create(
        "Unauthorized: Only doctors can view their upcoming appointments",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId).select(
    "firstName lastName avatar"
  );
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const today = moment().startOf("day").toDate();
  const appointments = await Appointment.find({
    doctorId,
    date: { $gte: today },
  })
    .populate("userId", "firstName lastName")
    .populate("childId", "name")
    .select("userId childId date time visitType status");

  const upcomingCount = appointments.length;

  const upcomingAppointments = appointments.map((appointment) => ({
    appointmentId: appointment._id,
    userName: `${appointment.userId.firstName} ${appointment.userId.lastName}`,
    childName: appointment.childId.name,
    place: appointment.visitType,
    date: moment(appointment.date).format("YYYY-MM-DD"),
    time: appointment.time,
    status:
      appointment.status === "Accepted"
        ? "ACCEPTED"
        : appointment.status === "Closed"
        ? "REFUSED"
        : "PENDING",
  }));

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      doctor: {
        name: `${doctor.firstName} ${doctor.lastName}`,
        avatar: doctor.avatar,
        upcomingCount: upcomingCount,
      },
      appointments: upcomingAppointments,
    },
  });
});

// ✅ جلب السجل الطبي وبيانات النمو بتاعة الطفل (بياخد childId من الـ Body)
const getChildRecords = asyncWrapper(async (req, res, next) => {
  const { childId } = req.body;
  const doctorId = req.user.id;

  // التحقق من وجود req.user و req.user.id
  if (!req.user || !req.user.id) {
    return next(
      appError.create(
        "Unauthorized: User ID not found in token",
        401,
        httpStatusText.FAIL
      )
    );
  }

  // التحقق من إن المستخدم دكتور
  if (req.user.role !== userRoles.DOCTOR) {
    return next(
      appError.create(
        "Unauthorized: Only doctors can access child records",
        403,
        httpStatusText.FAIL
      )
    );
  }

  // التحقق من إن doctorId صالح كـ ObjectId
  if (!mongoose.Types.ObjectId.isValid(doctorId)) {
    return next(
      appError.create("Invalid Doctor ID in token", 400, httpStatusText.FAIL)
    );
  }

  // التحقق من إن childId موجود في الـ Body
  if (!childId) {
    return next(
      appError.create(
        "Child ID is required in the body",
        400,
        httpStatusText.FAIL
      )
    );
  }

  // التحقق من إن childId صالح كـ ObjectId
  if (!mongoose.Types.ObjectId.isValid(childId)) {
    return next(appError.create("Invalid Child ID", 400, httpStatusText.FAIL));
  }

  // التحقق من إن الطفل موجود
  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  // جلب السجل الطبي (History)
  const medicalHistory = await History.find({ childId })
    .select(
      "diagnosis disease treatment notes date time doctorName notesImage createdAt updatedAt"
    )
    .sort({ date: -1 });

  // جلب بيانات النمو (Growth)
  const growthRecords = await Growth.find({ childId })
    .select(
      "weight height headCircumference date time notes notesImage ageInMonths createdAt updatedAt"
    )
    .sort({ date: -1 });

  res.json({
    status: httpStatusText.SUCCESS,
    data: {
      medicalHistory,
      growthRecords,
    },
  });
});

// ✅ جلب بيانات الدكتور (Profile)
const getDoctorProfile = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

  if (!doctorId) {
    return next(
      appError.create("User ID not found in token", 401, httpStatusText.FAIL)
    );
  }

  if (req.user.role !== userRoles.DOCTOR) {
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

// ✅ تعديل بيانات الدكتور (Profile)
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
    availableDays,
    availableTimes,
  } = req.body;

  if (req.user.role !== userRoles.DOCTOR) {
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

  if (firstName) doctor.firstName = firstName;
  if (lastName) doctor.lastName = lastName;
  if (email) doctor.email = email;
  if (phone) doctor.phone = phone;
  if (address) doctor.address = address;
  if (specialise) doctor.specialise = specialise;
  if (about) doctor.about = about;
  if (availableDays) doctor.availableDays = availableDays;
  if (availableTimes) doctor.availableTimes = availableTimes;

  await doctor.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Profile updated successfully",
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

// ✅ حذف الأكونت بتاع الدكتور (مع مسح الـ Token)
const deleteDoctorProfile = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

  if (!doctorId) {
    return next(
      appError.create("User ID not found in token", 401, httpStatusText.FAIL)
    );
  }

  if (req.user.role !== userRoles.DOCTOR) {
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

  // مسح الـ Token قبل الحذف
  doctor.token = null;
  await doctor.save();

  // حذف الأكونت
  await Doctor.deleteOne({ _id: doctorId });

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Doctor account deleted successfully",
  });
});

// ✅ تسجيل الخروج للدكتور
const logoutDoctor = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

  if (req.user.role !== userRoles.DOCTOR) {
    return next(
      appError.create(
        "Unauthorized: Only doctors can logout",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);
  if (doctor) {
    doctor.token = null;
    await doctor.save();
  }

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Logged out successfully",
  });
});

// ✅ إضافة دكتور للمفضلة (مع childId في الـ Path)
const addToFavorite = asyncWrapper(async (req, res, next) => {
  const { doctorId, childId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can add doctors to favorites",
        403,
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
        "Child not found or not associated with this user",
        404,
        httpStatusText.FAIL
      )
    );
  }

  if (child.favorite.includes(doctorId)) {
    return next(
      appError.create("Doctor already in favorites", 400, httpStatusText.FAIL)
    );
  }

  child.favorite.push(doctorId);
  await child.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Doctor added to favorites successfully",
  });
});

// ✅ إزالة دكتور من المفضلة (مع childId في الـ Path)
const removeFromFavorite = asyncWrapper(async (req, res, next) => {
  const { doctorId, childId } = req.params;
  const userId = req.user.id;

  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can remove doctors from favorites",
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

  if (!child.favorite.includes(doctorId)) {
    return next(
      appError.create("Doctor not found in favorites", 400, httpStatusText.FAIL)
    );
  }

  child.favorite = child.favorite.filter(
    (favId) => favId.toString() !== doctorId
  );
  await child.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Doctor removed from favorites successfully",
  });
});

module.exports = {
  getAllDoctors,
  getSingleDoctor,
  bookAppointment,
  getUserAppointments,
  updateAppointmentStatus,
  rescheduleAppointment,
  deleteAppointment,
  getUpcomingAppointments,
  getDoctorProfile,
  updateDoctorProfile,
  deleteDoctorProfile,
  logoutDoctor,
  addToFavorite,
  removeFromFavorite,
  getFavoriteDoctors,
  getChildRecords,
};
