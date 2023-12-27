state_abbreviations <- c(
  "AL", "AK", "AZ", "AR", "CA",
  "CO", "CT", "DE", "FL", "GA",
  "HI", "ID", "IL", "IN", "IA",
  "KS", "KY", "LA", "ME", "MD",
  "MA", "MI", "MN", "MS", "MO",
  "MT", "NE", "NV", "NH", "NJ",
  "NM", "NY", "NC", "ND", "OH",
  "OK", "OR", "PA", "RI", "SC",
  "SD", "TN", "TX", "UT", "VT",
  "VA", "WA", "WV", "WI", "WY"
)

narrative <- function(id, type = c("account", "cause", "summary")) {

  if(exists("narratives", where = .GlobalEnv)) {
    # Check if the object is a dataframe
    if(is.data.frame(get("narratives", envir = .GlobalEnv))) {
    } else {
      warning(paste("The object", "narratives", "exists but is not a dataframe."))
    }
  } else {
    warning(paste("The object", "narratives", "does not exist."))
  }

  if (type == "account") {
    thing <- narratives %>%
    filter(ev_id == id) %>%
    pull(narr_accp)
  } else if (type == "cause") {
    thing <- narratives %>%
    filter(ev_id == id) %>%
    pull(narr_cause)
  } else if (type == "summary") {
    thing <- narratives %>%
    filter(ev_id == id) %>%
    pull(narr_accf)
  }

  cat(strwrap(thing, width = 80), sep = "\n")

}
