% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/process_pva_date.R
\name{process_pva_date}
\alias{process_pva_date}
\title{Process Postal Vote Application Data by Date}
\usage{
process_pva_date(data, event)
}
\arguments{
\item{data}{A data frame containing PVA data for a single election event. Must include:
\itemize{
\item \code{date} (the date of the election or data snapshot)
\item \code{event} (the election event, matching the \code{event} argument)
}
Additional required columns vary by year:
\itemize{
\item 2010: \code{Enrolment}, and date-specific columns (e.g., "02 Aug 10").
\item 2013: \verb{Enrolment Division}, and date-specific columns (e.g., "20-Aug-13").
\item 2016: \code{State_Cd}, \code{PVA_Web_2_Date_Div}, and date-specific columns (e.g., "20160614").
\item 2019: \code{State_Cd}, \code{PVA_Web_2_Date_V2_Div}, and date-specific columns (e.g., "20190411").
}}

\item{event}{A character string specifying the election event to process. Recognised values are
"2010 Federal Election", "2013 Federal Election", "2016 Federal Election", or "2019 Federal Election".
Other values result in the data being returned unprocessed.}
}
\value{
A data frame with standardised columns for recognised election years:
\itemize{
\item \code{date} (the date of the election or data snapshot)
\item \code{event} (the election event)
\item \code{StateAb} (state abbreviation, upper case; "ZZZ" for NA in 2013)
\item \code{DivisionNm} (division name)
\item \code{DateReceived} (date the PVA was received, as a Date object)
\item \code{TotalPVAs} (total PVA applications received on the corresponding date)
}
For unrecognised years, the original data frame is returned unchanged.
}
\description{
Standardises and transforms Postal Vote Application (PVA) data for a single Australian federal
election event into a consistent long-format structure based on application receipt dates. This
function aligns column names across election years (2010, 2013, 2016, 2019), pivots date-specific
vote counts into a long format, and converts receipt dates to Date objects. For unrecognised
election years, the data is returned unprocessed with a message.
}
\details{
This function processes PVA data by:
\enumerate{
\item \strong{Standardising column names} across recognised election years using \code{rename_cols()}:
\itemize{
\item 2010: \code{Enrolment} to \code{DivisionNm}.
\item 2013: \verb{Enrolment Division} to \code{DivisionNm}.
\item 2016: \code{State_Cd} to \code{StateAb}, \code{PVA_Web_2_Date_Div} to \code{DivisionNm}.
\item 2019: \code{State_Cd} to \code{StateAb}, \code{PVA_Web_2_Date_V2_Div} to \code{DivisionNm}.
}
\item \strong{Handling missing states}: For 2013, NA in \code{StateAb} is replaced with "ZZZ".
\item \strong{Filtering rows}: For 2010 and 2013, rows with NA in \code{DivisionNm} (e.g., notes or totals) are removed.
\item \strong{Removing unnecessary columns}: Drops columns like "TOTAL to date (Inc GPV)" (2010, 2013),
"<>", and "Date out of range" (2019).
\item \strong{Pivoting data}: Uses \code{pivot_event()} to transform date-specific columns (e.g., "20-Aug-13")
into long format with \code{DateReceived} and \code{TotalPVAs}.
\item \strong{Converting dates}: Formats \code{DateReceived} as a Date object using year-specific formats:
\itemize{
\item 2019: "\%Y\%m\%d" (e.g., "20190411")
\item 2016: "\%Y\%m\%d" (e.g., "20160614")
\item 2013: "\%d-\%b-\%y" (e.g., "20-Aug-13")
\item 2010: "\%d \%b \%y" (e.g., "02 Aug 10")
}
\item \strong{Formatting}: Converts \code{StateAb} to uppercase.
\item \strong{Unrecognised years}: Returns the data unprocessed with an informative message.
}
The function assumes the input data frame contains the required columns (\code{date}, \code{event}, and
year-specific columns) from the AEC past results datasets and that the \code{event} column matches
the \code{event} argument. The date-specific columns represent daily PVA totals and are pivoted into
the \code{DateReceived} and \code{TotalPVAs} columns.
}
\examples{
# Sample 2010 data
data_2010 <- data.frame(
  date = "2010-08-21",
  event = "2010 Federal Election",
  StateAb = "VIC",
  Enrolment = "Melbourne",
  `02 Aug 10` = 50,
  `03 Aug 10` = 60
)
process_pva_date(data_2010, "2010 Federal Election")

# Sample invalid year
data_2022 <- data.frame(
  date = "2022-05-21",
  event = "2022 Federal Election",
  StateAb = "QLD",
  Votes = 90
)
process_pva_date(data_2022, "2022 Federal Election")

}
