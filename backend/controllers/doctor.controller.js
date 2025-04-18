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

  // استخدام Aggregation Pipeline للترتيب المطلوب
  const appointments = await Appointment.aggregate([
    // الشرط الأساسي: doctorId، التاريخ من اليوم وما بعد، واستبعاد Closed
    {
      $match: {
        doctorId: mongoose.Types.ObjectId(doctorId),
        date: { $gte: today },
        status: { $ne: "Closed" },
      },
    },
    // Populate userId و childId
    {
      $lookup: {
        from: "users",
        localField: "userId",
        foreignField: "_id",
        as: "userId",
      },
    },
    {
      $unwind: "$userId",
    },
    {
      $lookup: {
        from: "children",
        localField: "childId",
        foreignField: "_id",
        as: "childId",
      },
    },
    {
      $unwind: "$childId",
    },
    // إنشاء حقل مؤقت لتحويل date و time إلى تاريخ كامل للـ Accepted
    {
      $addFields: {
        appointmentDateTime: {
          $cond: {
            if: { $eq: ["$status", "Accepted"] },
            then: {
              $dateFromString: {
                dateString: {
                  $concat: [
                    { $dateToString: { format: "%Y-%m-%d", date: "$date" } },
                    "T",
                    "$time",
                  ],
                },
                format: "%Y-%m-%dT%H:%M %p",
              },
            },
            else: "$created_at", // للـ Pending، استخدم created_at
          },
        },
      },
    },
    // الترتيب
    {
      $sort: {
        status: 1, // Pending قبل Accepted
        appointmentDateTime: 1, // Pending حسب created_at، Accepted حسب date+time
      },
    },
    // اختيار الحقول المطلوبة
    {
      $project: {
        userId: {
          firstName: "$userId.firstName",
          lastName: "$userId.lastName",
        },
        childId: {
          name: "$childId.name",
        },
        date: 1,
        time: 1,
        visitType: 1,
        status: 1,
        _id: 1,
      },
    },
  ]);

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

  if (!req.user || !req.user.id) {
    return next(
      appError.create(
        "Unauthorized: User ID not found in token",
        401,
        httpStatusText.FAIL
      )
    );
  }

  if (req.user.role !== userRoles.DOCTOR) {
    return next(
      appError.create(
        "Unauthorized: Only doctors can access child records",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (!mongoose.Types.ObjectId.isValid(doctorId)) {
    return next(
      appError.create("Invalid Doctor ID in token", 400, httpStatusText.FAIL)
    );
  }

  if (!childId) {
    return next(
      appError.create(
        "Child ID is required in the body",
        400,
        httpStatusText.FAIL
      )
    );
  }

  if (!mongoose.Types.ObjectId.isValid(childId)) {
    return next(appError.create("Invalid Child ID", 400, httpStatusText.FAIL));
  }

  const child = await Child.findById(childId);
  if (!child) {
    return next(appError.create("Child not found", 404, httpStatusText.FAIL));
  }

  const medicalHistory = await History.find({ childId })
    .select(
      "diagnosis disease treatment notes date time doctorName notesImage createdAt updatedAt"
    )
    .sort({ date: -1 });

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
  const doctorEmail = req.user.email;

  console.log("Starting deleteDoctorProfile...");
  console.log("Doctor ID from token:", doctorId);
  console.log("Doctor Email from token:", doctorEmail);

  if (!doctorId) {
    console.log("No doctorId found in token");
    return next(
      appError.create("User ID not found in token", 401, httpStatusText.FAIL)
    );
  }

  if (!mongoose.Types.ObjectId.isValid(doctorId)) {
    console.log("Invalid doctorId format:", doctorId);
    return next(
      appError.create("Invalid Doctor ID in token", 400, httpStatusText.FAIL)
    );
  }

  if (req.user.role !== userRoles.DOCTOR) {
    console.log("User is not a doctor, role:", req.user.role);
    return next(
      appError.create(
        "Unauthorized: Only doctors can delete their profile",
        403,
        httpStatusText.FAIL
      )
    );
  }

  // التأكد من الاتصال بقاعدة البيانات
  console.log("Checking database connection...");
  const dbConnection = mongoose.connection;
  if (dbConnection.readyState !== 1) {
    console.log(
      "Database connection is not ready, state:",
      dbConnection.readyState
    );
    return next(
      appError.create("Database connection error", 500, httpStatusText.ERROR)
    );
  }
  console.log("Database connection is ready");

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    console.log("Doctor not found in database with ID:", doctorId);
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  console.log("Doctor found:", doctor.email);

  if (doctor.email !== doctorEmail) {
    console.log(
      "Email mismatch! Token email:",
      doctorEmail,
      "Doctor email:",
      doctor.email
    );
    return next(
      appError.create("Unauthorized: Email mismatch", 403, httpStatusText.FAIL)
    );
  }

  // استخدام Transaction للتأكد من إن كل العمليات بتتم مع بعض
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    console.log("Clearing doctor token...");
    doctor.token = null;
    await doctor.save({ session });
    console.log("Token cleared successfully");

    console.log("Deleting appointments for doctorId:", doctorId);
    const appointmentDeleteResult = await Appointment.deleteMany(
      { doctorId },
      { session }
    );
    console.log(
      "Appointments deleted:",
      appointmentDeleteResult.deletedCount,
      "appointments"
    );

    console.log("Deleting doctor with ID:", doctorId);
    const deleteResult = await Doctor.deleteOne({ _id: doctorId }, { session });
    if (deleteResult.deletedCount === 0) {
      console.log("Failed to delete doctor: No doctor found during deletion");
      throw new Error("Failed to delete doctor account");
    }

    const doctorAfterDelete = await Doctor.findById(doctorId).session(session);
    if (doctorAfterDelete) {
      console.log("Doctor still exists after deletion:", doctorAfterDelete);
      throw new Error("Doctor account was not deleted from the database");
    }

    console.log("Doctor deleted successfully");

    console.log("Removing doctor from favorites...");
    const favoriteUpdateResult = await Child.updateMany(
      { favorite: doctorId },
      { $pull: { favorite: doctorId } },
      { session }
    );
    console.log(
      "Favorites updated, modified documents:",
      favoriteUpdateResult.modifiedCount
    );

    // حذف الدكتور من جدول User (لو موجود)
    console.log("Deleting doctor from User collection...");
    const userDeleteResult = await User.deleteOne(
      { email: doctorEmail },
      { session }
    );
    console.log(
      "User deleted from User collection:",
      userDeleteResult.deletedCount,
      "users"
    );

    // Commit الـ Transaction
    await session.commitTransaction();
    console.log("Transaction committed successfully");

    res.json({
      status: httpStatusText.SUCCESS,
      message:
        "Doctor account, appointments, favorites, and user entry deleted successfully",
    });
  } catch (error) {
    // Rollback الـ Transaction لو حصل أي خطأ
    await session.abortTransaction();
    console.log("Transaction aborted due to error:", error.message);
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

  // البحث عن الدكتور
  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  // حذف الـ token
  doctor.token = null;
  await doctor.save();

  // الرد بنجاح
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

// ✅ تعديل الأيام والأوقات المتاحة للدكتور
const updateAvailability = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;
  const { availableDays, availableTimes } = req.body;

  if (req.user.role !== userRoles.DOCTOR) {
    return next(
      appError.create(
        "Unauthorized: Only doctors can update their availability",
        403,
        httpStatusText.FAIL
      )
    );
  }

  if (!availableDays && !availableTimes) {
    return next(
      appError.create(
        "At least one of availableDays or availableTimes is required",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  // التحقق من الأيام
  const validDays = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];
  if (availableDays) {
    if (!Array.isArray(availableDays)) {
      return next(
        appError.create(
          "availableDays must be an array",
          400,
          httpStatusText.FAIL
        )
      );
    }
    // التحقق من إن مفيش أيام فاضية أو مكررة
    const trimmedDays = availableDays.map((day) => day.trim());
    const uniqueDays = [...new Set(trimmedDays)];
    const invalidDays = uniqueDays.filter(
      (day) => !validDays.includes(day) || day === ""
    );
    if (invalidDays.length > 0) {
      return next(
        appError.create(
          `Invalid days: ${invalidDays.join(
            ", "
          )}. Days must be one of: ${validDays.join(", ")}`,
          400,
          httpStatusText.FAIL
        )
      );
    }
    doctor.availableDays = uniqueDays;
  }

  // التحقق من الأوقات
  if (availableTimes) {
    if (!Array.isArray(availableTimes)) {
      return next(
        appError.create(
          "availableTimes must be an array",
          400,
          httpStatusText.FAIL
        )
      );
    }
    const timeFormatRegex = /^(1[0-2]|0?[1-9]):([0-5][0-9]) (AM|PM)$/i;
    // التحقق من إن مفيش أوقات فاضية أو مكررة
    const trimmedTimes = availableTimes.map((time) =>
      time.trim().toUpperCase()
    );
    const uniqueTimes = [...new Set(trimmedTimes)];
    const invalidTimes = uniqueTimes.filter(
      (time) => !timeFormatRegex.test(time) || time === ""
    );
    if (invalidTimes.length > 0) {
      return next(
        appError.create(
          `Invalid times: ${invalidTimes.join(
            ", "
          )}. Times must be in the format HH:MM AM/PM (e.g., 9:00 AM)`,
          400,
          httpStatusText.FAIL
        )
      );
    }
    doctor.availableTimes = uniqueTimes;
  }

  await doctor.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Availability updated successfully",
    data: {
      availableDays: doctor.availableDays,
      availableTimes: doctor.availableTimes,
    },
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
  getDoctorProfile,//
  updateDoctorProfile,//
  deleteDoctorProfile,//
  logoutDoctor,//
  addToFavorite,
  removeFromFavorite,
  getFavoriteDoctors,
  getChildRecords,
  updateAvailability,
};
