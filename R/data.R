#' ABS Census Table Descriptions
#'
#' A dataset containing the table numbers and descriptions for ABS Census
#' DataPack tables. This can be used to look up what data each table contains
#' before downloading with \code{get_census_data}.
#'
#' @format A data frame with 108 rows and 3 variables:
#' \describe{
#'   \item{table}{Character. The table identifier (e.g., "G01", "B01"). Tables with
#'     G-prefix are from the General Community Profile (2016, 2021). Tables with
#'     B-prefix are from the Basic Community Profile (2011).}
#'   \item{description}{Character. A description of the table contents.}
#'   \item{census_years}{Character. Comma-separated list of Census years where this
#'     table is available (e.g., "2016,2021" or "2011").}
#' }
#'
#' @details
#' The ABS Census DataPacks contain pre-defined tables of Census data at SA1
#' geographic level. The table numbering differs between Census years:
#' \itemize{
#'   \item \strong{2021 and 2016}: Use General Community Profile (GCP) tables with
#'     G-prefix (G01 through G62)
#'   \item \strong{2011}: Uses Basic Community Profile (BCP) tables with B-prefix
#'     (B01 through B46)
#' }
#'
#' Note that some tables are only available in certain Census years. For example,
#' tables G19-G22 (health conditions and defence force service) are only available
#' in the 2021 Census.
#'
#' @examples
#' # View all available tables
#' head(abs_census_tables)
#'
#' # Find tables related to income
#' abs_census_tables[grep("income", abs_census_tables$description, ignore.case = TRUE), ]
#'
#' # Find tables available in 2021
#' abs_census_tables[grep("2021", abs_census_tables$census_years), ]
#'
#' # Find 2011 Census tables (B-prefix)
#' abs_census_tables[grep("^B", abs_census_tables$table), ]
#'
#' @seealso \code{get_census_data} to download Census data
#'
#' @source Australian Bureau of Statistics Census DataPacks
#'   \url{https://www.abs.gov.au/census/find-census-data/datapacks}
#'
"abs_census_tables"
