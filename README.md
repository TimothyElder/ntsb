# NTSB

Some analyses of accident data collected by the National Transportation Safety Board. The data is provided in Microsoft Access databases and is converted to CSV and then to a SQL database. The data is broken up across a number of different tables can be downloaded using the `get-data.sh` script, then transformed to CSVs with the `mdb-export-all.sh` script.

```sh
sh scripts/get-data.sh
sh scripts/mdb-export-all.sh ../data/avall.mdb
```

The NTSB investigates aviation "accidents" which are separate from "incidents" which are typically investigated by the Federal Aviation Administration. An event is defined as an "accident" or "incident" depending on the degree of damage to the aircraft and the highest level of injury sustained in the event.

# Variables

## `events` table

`mid_air`: indicator (Y/N) of whether the event was a mid-air collision, single event with two aircraft

`ev_time`: The local time of the event in 4-digit, 24-hour format.

`gust_ind`: (Not Gusting, Unknown, Gusting) Indicate whether gusting winds were reported locally at the time of the event. Gusting wind is defined in chapter 5 of the Federal Meteorological Handbook as rapid fluctuations in wind speed with a variation of 10 knots or more between peaks and lulls.

`gust_kts`: Wind Gust (knots) if reported.

`inj_f_grnd`: (Count) On Ground, Fatal Injuries

`inj_m_grnd`: (Count) On Ground, Minor Injuries

`inj_s_grnd`: (Count) On Ground, Serious Injuries

`on_ground_collision`: indicator (Yes/No) On Ground Collision occurred

`inj_tot_f`: (Count) Total number of fatalities

`inj_tot_m`: (Count) Total number of minor injured

`inj_tot_n`: (Count) Total number non-injured

`inj_tot_s`: (Count) Total number of serious injured

`inj_tot_t`: (Count, $F + S + M$) Total number of injured, sum of previous columns

`wx_int_precip`: Intensity of Precipitation (Heavy, Light, Moderate, Unknown)

## `aircraft` table 

`acft_category`: Aircraft Category (Airplane, Balloon, Blimp, Glider, Gyrocraft, Helicopter, Powered-Lift, Ultralight, Unknown, Powered parachute, Weight shift)

`acft_make`: Aircraft Manufacturer's Full Name

`acft_model`: Aircraft Model

`cc_seats`: (Count) Refers to the number of aircraft seats by type.

`damage`: Indicate the severity of damage to the accident aircraft. For the purposes of this variable, aircraft damage categories are defined in 49 CFR 830.2. (Destroyed, Minor, None, Substantial, Unknown)

`dprt_apt_id`: Departure Airport Code.

`dprt_city`: The city address of the involved aircraft's last departure point prior to the event.

`dest_apt_id`: Destination Airport Code

`dest_city`: Indicate the city address of the involved aircraft's intended destination.

`oper_name`: The full name of the operator of the accident aircraft. This typically refers to an organization or group (e.g., airline or corporation) rather than the pilot.

`pax_seats`: (Count) Passenger Seats

`total_seats`: Total number of seats on the aircraft.

`acft_year`: Year of Manufacture