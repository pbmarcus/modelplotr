% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataprepmodelplots.R
\name{input_modevalplots}
\alias{input_modevalplots}
\title{Build 'eval_t_tot' with aggregated evaluation measures}
\usage{
input_modevalplots(prepared_input = eval_tot)
}
\arguments{
\item{eval_tot}{Dataframe resulting from function dataprep_modevalplots().}
}
\value{
Dataframe \code{eval_t_tot} is built based on \code{eval_tot}.
\code{eval_t_tot} contains:
\tabular{lll}{
  \bold{column} \tab \bold{type} \tab \bold{definition} \cr
  modelname \tab String \tab Name of the model object \cr
  dataset \tab Factor \tab Datasets to include in the plot as factor levels\cr
  category\tab String or Integer\tab Target values to include in the plot\cr
  decile\tab Integer\tab Decile groups based on model probability for category\cr
  neg\tab Integer\tab Number of cases not belonging to category in dataset in decile\cr
  pos\tab Integer\tab Number of cases belonging to category in dataset in decile\cr
  tot\tab Integer\tab Total number of cases in dataset in decile\cr
  pct\tab Decimal \tab Percentage of cases in dataset in decile that belongs to
  category (pos/tot)\cr
  negtot\tab Integer\tab Total number of cases not belonging to category in dataset\cr
  postot\tab Integer\tab Total number of cases belonging to category in dataset\cr
  tottot\tab Integer\tab Total number of cases in dataset\cr
  pcttot\tab Decimal\tab Percentage of cases in dataset that belongs to
  category (postot / tottot)\cr
  cumneg\tab Integer\tab Cumulative number of cases not belonging to category in
  dataset from decile 1 up until decile\cr
  cumpos\tab Integer\tab Cumulative number of cases belonging to category in
  dataset from decile 1 up until decile\cr
  cumpos\tab Integer\tab Cumulative number of cases belonging to category in
  dataset from decile 1 up until decile\cr
  cumtot\tab Integer\tab Cumulative number of cases in dataset from decile 1
  up until decile\cr
  gain\tab Decimal\tab Gains value for dataset for decile (pos/postot)\cr
  cumgain\tab Decimal\tab Cumulative gains value for dataset for decile
  (cumpos/postot)\cr
  gain_ref\tab Decimal\tab Lower reference for gains value for dataset for decile
  (decile/10)\cr
  gain_opt\tab Decimal\tab Upper reference for gains value for dataset for decile\cr
  lift\tab Decimal\tab Lift value for dataset for decile (pct/pcttot)\cr
  cumlift\tab Decimal\tab Cumulative lift value for dataset for decile
  ((cumpos/cumtot)/pcttot)\cr
  cumlift_ref\tab Decimal\tab Reference value for Cumulative lift value (constant: 1)
 }
}
\description{
Build dataframe 'eval_t_tot' with aggregated actuals and predictions .
A record in 'eval_t_tot' is unique on the combination of datasets-decile.
}
\examples{
add(1, 1)
add(10, 10)
}
\seealso{
\code{\link{dataprep_modevalplots}} for details on the function that generated the required input.
}
