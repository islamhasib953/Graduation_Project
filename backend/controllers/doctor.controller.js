const Doctor = require("../models/doctor.model");
const User = require("../models/user.model");
const Appointment = require("../models/appointment.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const userRoles = require("../utils/userRoles");
const moment = require("moment");

// ✅ عرض كل الدكاترة
const getAllDoctors = asyncWrapper(async (req, res, next) => {
  const doctors = await Doctor.find().select(
    "firstName lastName phone availableTimes availableDays created_at address avatar specialise about rate"
  );

  if (!doctors.length) {
    return next(appError.create("No doctors found", 404, httpStatusText.FAIL));
  }

  const currentDay = moment().format("dddd");
  const currentHour = moment().format("h A");

  const doctorsWithStatus = await Promise.all(
    doctors.map(async (doctor) => {
      // التحقق من وجود أيام وأوقات متاحة
      const hasAvailableDays =
        doctor.availableDays && doctor.availableDays.length > 0;
      const hasAvailableTimes =
        doctor.availableTimes && doctor.availableTimes.length > 0;

      // إذا لم يكن هناك أيام أو أوقات متاحة، يظهر الدكتور كـ Closed
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
          status: "Closed", // الدكتور مغلق لعدم وجود مواعيد
        };
      }

      // جلب كل المواعيد المحجوزة للدكتور
      const bookedAppointments = await Appointment.find({
        doctorId: doctor._id,
        date: { $gte: moment().startOf("day").toDate() },
      }).select("date time");

      // حساب عدد المواعيد المحجوزة لكل يوم ووقت
      const bookedSlots = bookedAppointments.map((appointment) => ({
        date: moment(appointment.date).format("YYYY-MM-DD"),
        time: appointment.time,
      }));

      // إنشاء قائمة بالمواعيد المتاحة بناءً على الأيام والأوقات
      const availableSlots = [];
      doctor.availableDays.forEach((day) => {
        doctor.availableTimes.forEach((time) => {
          // نفترض إننا بنحسب المواعيد المتاحة لمدة 30 يوم من اليوم
          for (let i = 0; i < 30; i++) {
            const futureDate = moment().add(i, "days");
            if (futureDate.format("dddd") === day) {
              availableSlots.push({
                date: futureDate.format("YYYY-MM-DD"),
                time: time,
              });
            }
          }
        });
      });

      // التحقق من إذا كان فيه مواعيد متاحة بعد مقارنة المحجوز مع المتاح
      let hasAvailableSlot = false;
      for (const slot of availableSlots) {
        const isBooked = bookedSlots.some(
          (booked) => booked.date === slot.date && booked.time === slot.time
        );
        if (!isBooked) {
          hasAvailableSlot = true;
          break;
        }
      }

      // تحديد حالة الدكتور بناءً على الوقت الحالي وتوفر المواعيد
      const isDayAvailable = doctor.availableDays.includes(currentDay);
      const isTimeAvailable = doctor.availableTimes.some((time) => {
        const availableHour = moment(time, "h:mm A").format("h A");
        return availableHour === currentHour;
      });

      const status =
        hasAvailableSlot && isDayAvailable && isTimeAvailable
          ? "Open"
          : "Closed";

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
      };
    })
  );

  res.json({
    status: httpStatusText.SUCCESS,
    data: doctorsWithStatus,
  });
});

// ✅ عرض تفاصيل دكتور معين
const getSingleDoctor = asyncWrapper(async (req, res, next) => {
  const { doctorId } = req.params;

  const doctor = await Doctor.findById(doctorId).select(
    "firstName lastName phone availableTimes availableDays created_at address avatar specialise about rate"
  );

  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const currentDay = moment().format("dddd");
  const currentHour = moment().format("h A");

  // التحقق من وجود أيام وأوقات متاحة
  const hasAvailableDays =
    doctor.availableDays && doctor.availableDays.length > 0;
  const hasAvailableTimes =
    doctor.availableTimes && doctor.availableTimes.length > 0;

  // إذا لم يكن هناك أيام أو أوقات متاحة، يظهر الدكتور كـ Closed
  let status = "Closed";
  let hasAvailableSlot = false;

  if (hasAvailableDays && hasAvailableTimes) {
    // جلب كل المواعيد المحجوزة للدكتور
    const bookedAppointments = await Appointment.find({
      doctorId: doctor._id,
      date: { $gte: moment().startOf("day").toDate() },
    }).select("date time");

    // حساب عدد المواعيد المحجوزة لكل يوم ووقت
    const bookedSlots = bookedAppointments.map((appointment) => ({
      date: moment(appointment.date).format("YYYY-MM-DD"),
      time: appointment.time,
    }));

    // إنشاء قائمة بالمواعيد المتاحة بناءً على الأيام والأوقات
    const availableSlots = [];
    doctor.availableDays.forEach((day) => {
      doctor.availableTimes.forEach((time) => {
        for (let i = 0; i < 30; i++) {
          const futureDate = moment().add(i, "days");
          if (futureDate.format("dddd") === day) {
            availableSlots.push({
              date: futureDate.format("YYYY-MM-DD"),
              time: time,
            });
          }
        }
      });
    });

    // التحقق من إذا كان فيه مواعيد متاحة بعد مقارنة المحجوز مع المتاح
    for (const slot of availableSlots) {
      const isBooked = bookedSlots.some(
        (booked) => booked.date === slot.date && booked.time === slot.time
      );
      if (!isBooked) {
        hasAvailableSlot = true;
        break;
      }
    }

    // تحديد الحالة بناءً على الوقت الحالي وتوفر المواعيد
    const isDayAvailable = doctor.availableDays.includes(currentDay);
    const isTimeAvailable = doctor.availableTimes.some((time) => {
      const availableHour = moment(time, "h:mm A").format("h A");
      return availableHour === currentHour;
    });

    status =
      hasAvailableSlot && isDayAvailable && isTimeAvailable ? "Open" : "Closed";
  }

  const bookedAppointments = await Appointment.find({ doctorId }).select(
    "date time"
  );

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
    },
  });
});

// ✅ حجز موعد مع دكتور
const bookAppointment = asyncWrapper(async (req, res, next) => {
  const { doctorId } = req.params;
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

  const doctor = await Doctor.findById(doctorId);

  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  // التحقق من وجود أيام وأوقات متاحة
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

  // التحقق من إذا كان فيه مواعيد متاحة
  const bookedAppointments = await Appointment.find({
    doctorId: doctor._id,
    date: { $gte: moment().startOf("day").toDate() },
  }).select("date time");

  const bookedSlots = bookedAppointments.map((appointment) => ({
    date: moment(appointment.date).format("YYYY-MM-DD"),
    time: appointment.time,
  }));

  const availableSlots = [];
  doctor.availableDays.forEach((day) => {
    doctor.availableTimes.forEach((time) => {
      for (let i = 0; i < 30; i++) {
        const futureDate = moment().add(i, "days");
        if (futureDate.format("dddd") === day) {
          availableSlots.push({
            date: futureDate.format("YYYY-MM-DD"),
            time: time,
          });
        }
      }
    });
  });

  let hasAvailableSlot = false;
  for (const slot of availableSlots) {
    const isBooked = bookedSlots.some(
      (booked) => booked.date === slot.date && booked.time === slot.time
    );
    if (!isBooked) {
      hasAvailableSlot = true;
      break;
    }
  }

  if (!hasAvailableSlot) {
    return next(
      appError.create(
        "No available slots for booking with this doctor",
        400,
        httpStatusText.FAIL
      )
    );
  }

  // التحقق من إن اليوم والوقت المطلوبين متاحين
  const requestedDay = moment(date).format("dddd");
  const isDayAvailable = doctor.availableDays.includes(requestedDay);
  const isTimeAvailable = doctor.availableTimes.includes(time);

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
    time,
  });

  if (existingAppointment) {
    return next(
      appError.create(
        "This appointment is already booked",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const newAppointment = new Appointment({
    userId,
    doctorId,
    date: moment(date).startOf("day").toDate(),
    time,
    visitType,
  });

  await newAppointment.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Appointment booked successfully",
    data: {
      appointmentId: newAppointment._id,
      doctorId: doctor._id,
      date: moment(newAppointment.date).format("YYYY-MM-DD"),
      time,
      visitType,
    },
  });
});

// ✅ جلب كل الحجوزات بتاعة اليوزر
const getUserAppointments = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;

  const appointments = await Appointment.find({ userId })
    .populate("doctorId", "firstName lastName avatar address")
    .select("doctorId date time visitType status created_at");

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

// ✅ تعديل موعد الحجز (Reschedule)
const rescheduleAppointment = asyncWrapper(async (req, res, next) => {
  const { appointmentId } = req.params;
  const { date, time } = req.body;
  const userId = req.user.id;

  if (!date || !time) {
    return next(
      appError.create("Date and time are required", 400, httpStatusText.FAIL)
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

  if (appointment.status === "Accepted") {
    return next(
      appError.create(
        "Cannot reschedule an accepted appointment. You can only cancel it.",
        400,
        httpStatusText.FAIL
      )
    );
  }

  const existingAppointment = await Appointment.findOne({
    doctorId: appointment.doctorId,
    date,
    time,
    _id: { $ne: appointmentId },
  });

  if (existingAppointment) {
    return next(
      appError.create(
        "This new time slot is already booked",
        400,
        httpStatusText.FAIL
      )
    );
  }

  appointment.date = date;
  appointment.time = time;
  await appointment.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Appointment rescheduled successfully",
    data: {
      appointmentId: appointment._id,
      date: appointment.date,
      time: appointment.time,
    },
  });
});

// ✅ إلغاء الحجز
const deleteAppointment = asyncWrapper(async (req, res, next) => {
  const { appointmentId } = req.params;
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

  await Appointment.deleteOne({ _id: appointmentId });

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Appointment deleted successfully",
  });
});

// ✅ جلب كل الحجوزات القادمة للدكتور
const getUpcomingAppointments = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

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
    .select("userId date time visitType status");

  const upcomingCount = appointments.length;

  const upcomingAppointments = appointments.map((appointment) => ({
    userName: `${appointment.userId.firstName} ${appointment.userId.lastName}`,
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

// ✅ جلب بيانات الدكتور (Profile)
const getDoctorProfile = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

  // نجيب كل الحقول ما عدا password و token باستخدام -password -token في الـ select
  const doctor = await Doctor.findById(doctorId).select("-password -token");

  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  // نرجع كل البيانات اللي جبناها من الـ doctor
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
  const { firstName, lastName, email, phone } = req.body;

  const doctor = await Doctor.findById(doctorId);

  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  if (firstName) doctor.firstName = firstName;
  if (lastName) doctor.lastName = lastName;
  if (email) doctor.email = email;
  if (phone) doctor.phone = phone;

  await doctor.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Profile updated successfully",
    data: {
      firstName: doctor.firstName,
      lastName: doctor.lastName,
      email: doctor.email,
      phone: doctor.phone,
      avatar: doctor.avatar,
    },
  });
});

// ✅ تسجيل الخروج للدكتور
const logoutDoctor = asyncWrapper(async (req, res, next) => {
  res.json({
    status: httpStatusText.SUCCESS,
    message: "Logged out successfully",
  });
});

// ✅ إضافة دكتور للمفضلة
const addToFavorite = asyncWrapper(async (req, res, next) => {
  const { doctorId } = req.params;
  const userId = req.user.id;

  const doctor = await Doctor.findById(doctorId);
  if (!doctor) {
    return next(appError.create("Doctor not found", 404, httpStatusText.FAIL));
  }

  const user = await User.findById(userId);
  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  if (user.favorite.includes(doctorId)) {
    return next(
      appError.create("Doctor already in favorites", 400, httpStatusText.FAIL)
    );
  }

  user.favorite.push(doctorId);
  await user.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Doctor added to favorites successfully",
  });
});

// ✅ إزالة دكتور من المفضلة
const removeFromFavorite = asyncWrapper(async (req, res, next) => {
  const { doctorId } = req.params;
  const userId = req.user.id;

  const user = await User.findById(userId);
  if (!user) {
    return next(appError.create("User not found", 404, httpStatusText.FAIL));
  }

  if (!user.favorite.includes(doctorId)) {
    return next(
      appError.create("Doctor not found in favorites", 400, httpStatusText.FAIL)
    );
  }

  user.favorite = user.favorite.filter(
    (favId) => favId.toString() !== doctorId
  );
  await user.save();

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
  logoutDoctor,
  addToFavorite,
  removeFromFavorite,
};
