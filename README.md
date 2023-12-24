# NTSB

Some analyses of accident data collected by the National Transportation Safety Board. The data is provided in Microsoft Access databases and is converted to CSV and then to a SQL database. The data is broken up across a number of different tables can be downloaded using the `get-data.sh` script.

# Install

```sh
sh scripts/get-data.sh
sh scripts/mdb2sqlite.sh avall.mdb
```

## Some Important Variables

`inj_tot_f` == Total number of fatalities
`inj_tot_m` == Total number of minor injured
`inj_tot_n` == Total number non-injured
`inj_tot_s` == Total number of serious injured
`inj_tot_t` == Total number of injured, sum of previous columns