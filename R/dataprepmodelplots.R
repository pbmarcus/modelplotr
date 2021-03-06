

#' Build 'eval_tot' containing Actuals and Predictions
#'
#' Build dataframe object 'eval_tot' that contains actuals and predictions on
#' dependent variable for each dataset in datasets
#' @param datasets List of strings. A list of the names of the dataframe
#'   objects to include in model evaluation. All dataframes need to contain
#'   target variable and feature variables. Default value is list("train","set"),
#'   hence the presence of objects named "train" and "test" in the environment is
#'   expected.
#' @param datasetlabels List of strings. A list of labels for the datasets, user.
#'   When not specified, the dataset name is used.
#' @param models List of Strings. Names of the model objects containing parameters to
#'   apply models to data.
#' @param modellabels List of String. Labels for the models to use in plots.
#' @param targetname String. Name of the target variable in datasets. Target
#'   can be either binary or multinomial. Continuous targets are not supported.
#' @return Dataframe. Dataframe 'eval_tot' is built based on \code{datasets}.
#'   It contains the dataset name, actuals on the target \code{target} , the
#'   predicted probabilities for each class of the target and attribution to
#'   deciles in the dataset for each class of the target.
#' @seealso \code{\link{input_modevalplots}} for details on the function that
#' aggregates the output to the input for the plots.
#' @seealso \url{https://github.com/jurrr/modelplotr} for details on the package
#' @seealso \url{https://cmotions.nl/publicaties/} for our blog on the value of the model plots
#' @examples
#' data(iris)
#' colnames(iris) = c('sepal_length', 'sepal_width', 'petal_length',
#' 'petal_width', 'species')
#' test_size = 0.3
#' train_index =  sample(seq(1, nrow(iris)),size = (1 - test_size)*nrow(iris) ,
#' replace = F )
#' train = iris[train_index,]
#' test = iris[-train_index,]
#' rf <- randomForest::randomForest(species ~ ., data=train, importance = T,ntree=5)
#' mnl <- nnet::multinom(species ~ ., data = train)
#' dataprep_modevalplots(datasets=list("train","test"),
#'                       datasetlabels = list("train data","test data"),
#'                       models = list("rf","mnl"),
#'                       modellabels = list("random forest","multinomial logit"),
#'                       targetname="species")
#' head(eval_tot)
#' input_modevalplots()
#' cumgains()
#' lift()
#' response()
#' cumresponse()
#' multiplot(cumgains,lift,response,cumresponse,cols=2)
#' @export
#' @importFrom magrittr %>%
dataprep_modevalplots <- function(datasets = list("train","test"),
                                  datasetlabels,
                                  models ,
                                  modellabels ,
                                  targetname="y"){
  if(missing(datasetlabels)) datasetlabels = datasets
  if(missing(modellabels)) modellabels = models
  eval_tot = data.frame()
  # create per dataset (train, test,...) a set with y, y_pred, p_y and dec_y

  for (dataset in datasets) {
    for (mdl in models) {

      # 1.1. get category prediction from model (NOT YET DYNAMIC!) and prepare
      actuals = get(dataset) %>% dplyr::select_(y_true=targetname)

      # 1.2. get probabilities per target category from model and prepare
      probabilities = as.data.frame(predict(get(mdl),newdata=get(dataset),
                                            type = "prob"))

      #name probability per target category
      y_values = colnames(probabilities)
      colnames(probabilities) = paste0('prob_',y_values)
      y_probvars = colnames(probabilities)

      probabilities = cbind(modelname=unlist(modellabels[match(mdl,models)]),
                            dataset=unlist(datasetlabels[match(dataset,datasets)]),
                            actuals,
                            probabilities)

      # 1.3. calculate deciles per target category
      for (i in 1:length(y_values)) {
        #! Added small proportion to prevent equal decile bounds
        # and reset to 0-1 range (to prevent probs > 1.0)
        range01 <- function(x){(x-min(x))/(max(x)-min(x))}
        prob_plus_smallrandom = range01(probabilities[,y_probvars[i]]+
            runif(NROW(probabilities))/1000000)
        # determine cutoffs based on prob_plus_smallrandom
        cutoffs = c(quantile(prob_plus_smallrandom,probs = seq(0,1,0.1),
                             na.rm = TRUE))
        # add decile variable per y-class
        probabilities[,paste0('dcl_',y_values[i])] <- 11-as.numeric(
          cut(prob_plus_smallrandom,breaks=cutoffs,include.lowest = T))
      }
      eval_tot = rbind(eval_tot,probabilities)
    }
  }
  eval_tot <<- eval_tot
  return('Data preparation step 1 succeeded! Dataframe \'eval_tot\' created.')
}

#' Build 'eval_t_tot' with aggregated evaluation measures
#'
#' Build dataframe 'eval_t_tot' with aggregated actuals and predictions .
#' A record in 'eval_t_tot' is unique on the combination of datasets-decile.
#' @param eval_tot Dataframe resulting from function dataprep_modevalplots().
#' @return Dataframe \code{eval_t_tot} is built based on \code{eval_tot}.
#' \code{eval_t_tot} contains:
#' \tabular{lll}{
#'   \bold{column} \tab \bold{type} \tab \bold{definition} \cr
#'   modelname \tab String \tab Name of the model object \cr
#'   dataset \tab Factor \tab Datasets to include in the plot as factor levels\cr
#'   category\tab String or Integer\tab Target values to include in the plot\cr
#'   decile\tab Integer\tab Decile groups based on model probability for category\cr
#'   neg\tab Integer\tab Number of cases not belonging to category in dataset in decile\cr
#'   pos\tab Integer\tab Number of cases belonging to category in dataset in decile\cr
#'   tot\tab Integer\tab Total number of cases in dataset in decile\cr
#'   pct\tab Decimal \tab Percentage of cases in dataset in decile that belongs to
#'   category (pos/tot)\cr
#'   negtot\tab Integer\tab Total number of cases not belonging to category in dataset\cr
#'   postot\tab Integer\tab Total number of cases belonging to category in dataset\cr
#'   tottot\tab Integer\tab Total number of cases in dataset\cr
#'   pcttot\tab Decimal\tab Percentage of cases in dataset that belongs to
#'   category (postot / tottot)\cr
#'   cumneg\tab Integer\tab Cumulative number of cases not belonging to category in
#'   dataset from decile 1 up until decile\cr
#'   cumpos\tab Integer\tab Cumulative number of cases belonging to category in
#'   dataset from decile 1 up until decile\cr
#'   cumpos\tab Integer\tab Cumulative number of cases belonging to category in
#'   dataset from decile 1 up until decile\cr
#'   cumtot\tab Integer\tab Cumulative number of cases in dataset from decile 1
#'   up until decile\cr
#'   gain\tab Decimal\tab Gains value for dataset for decile (pos/postot)\cr
#'   cumgain\tab Decimal\tab Cumulative gains value for dataset for decile
#'   (cumpos/postot)\cr
#'   gain_ref\tab Decimal\tab Lower reference for gains value for dataset for decile
#'   (decile/10)\cr
#'   gain_opt\tab Decimal\tab Upper reference for gains value for dataset for decile\cr
#'   lift\tab Decimal\tab Lift value for dataset for decile (pct/pcttot)\cr
#'   cumlift\tab Decimal\tab Cumulative lift value for dataset for decile
#'   ((cumpos/cumtot)/pcttot)\cr
#'   cumlift_ref\tab Decimal\tab Reference value for Cumulative lift value (constant: 1)
#'  }
#' @seealso \code{\link{dataprep_modevalplots}} for details on the function that generated the required input.
#' @examples
#' add(1, 1)
#' add(10, 10)
#' @export
#' @importFrom magrittr %>%
input_modevalplots <- function(prepared_input=eval_tot){

  # check if eval_tot exists, otherwise create
  if (!(exists("eval_tot"))) dataprep_modevalplots()

  modelgroups = levels(prepared_input$dataset)
  yvals = levels(prepared_input$y_true)

  eval_t_tot <- data.frame()


  for (val in yvals) {

    eval_t_zero = eval_tot %>%
      dplyr::mutate("category"=val,"decile"=0) %>%
      dplyr::group_by_("modelname","dataset","category","decile") %>%
      dplyr::summarize(neg=0,
                pos=0,
                tot=0,
                pct=NA,
                negtot=NA,
                postot=NA,
                tottot=NA,
                pcttot=NA,
                cumneg=0,
                cumpos=0,
                cumtot=0,
                cumpct=NA,
                gain=0,
                cumgain=0,
                gain_ref=0,
                gain_opt=0,
                lift=NA,
                cumlift=NA,
                cumlift_ref = 1) %>%
      as.data.frame()

    eval_t_add = eval_tot %>%
      dplyr::mutate("category"=val,"decile"=get(paste0("dcl_",val))) %>%
      dplyr::group_by_("modelname","dataset","category","decile") %>%
      dplyr::summarize(neg=sum(y_true!=category),
                pos=sum(y_true==category),
                tot=n(),
                pct=1.0*sum(y_true==category)/n()) %>%
      dplyr::group_by_("modelname","dataset","category") %>%
      dplyr::mutate(negtot=sum(neg),
             postot=sum(pos),
             tottot=sum(tot),
             pcttot=1.0*sum(pos)/sum(tot)) %>%
      dplyr::group_by_("modelname","dataset","category","negtot","postot","tottot","pcttot") %>%
      dplyr::mutate(cumneg=cumsum(neg),
             cumpos=cumsum(pos),
             cumtot=cumsum(tot),
             cumpct=1.0*cumsum(pos)/cumsum(tot),
             gain=pos/postot,
             cumgain=cumsum(pos)/postot,
             gain_ref=decile/10,
             gain_opt=ifelse(decile>=ceiling(10*pcttot),1,(decile/10)/(ceiling(10*pcttot)/10)),
             lift=pct/pcttot,
             cumlift=1.0*cumsum(pos)/cumsum(tot)/pcttot,
             cumlift_ref = 1) %>%
      as.data.frame()

    eval_t_tot = rbind(eval_t_tot,eval_t_zero,eval_t_add)
    eval_t_tot = eval_t_tot[with(eval_t_tot,order(category,dataset,decile)),]
  }
  eval_t_tot <<- eval_t_tot
  return('Data preparation step 2 succeeded! Dataframe \'eval_t_tot\' created.')

}


#' Build 'eval_t_type' with subset for selected evaluation type.
#'
#' Build dataframe 'eval_t_type' subset for selected evaluation type.
#' There are three perspectives to take:
#' .
#' @param eval_t_tot Dataframe resulting from function dataprep_modevalplots().
#' @return Dataframe \code{eval_t_type} is a subset of \code{eval_t_tot}.
#' @seealso \code{\link{input_modevalplots}} for details on the function that generated the required input.
#' @examples
#' add(1, 1)
#' add(10, 10)
#' @export
#' @importFrom magrittr %>%
scope_modevalplots <- function(prepared_input=eval_t_tot,
                               eval_type=c("CompareTrainTest","CompareModels","TargetValues"),
                               select_model,
                               select_dataset,
                               select_targetvalue){

  # check if eval_tot exists, otherwise create
  if (!(exists("eval_t_tot"))) input_modevalplots()
  if (missing(select_model)) select_model <- unique(prepared_input$modelname)[1]
  if (missing(select_dataset)) select_dataset <- unique(prepared_input$dataset)[1]
  if (missing(select_targetvalue)) select_targetvalue <- unique(prepared_input$category)[1]

  eval_t_type <- prepared_input %>%
    {if (eval_type=="CompareTrainTest") dplyr::filter(., modelname == select_model & category == select_targetvalue) %>%
        dplyr::mutate(.,lines=dataset)
    else if (eval_type=="CompareModels") dplyr::filter(., dataset == select_dataset & category == select_targetvalue) %>%
        dplyr::mutate(.,lines=modelname)
    else if (eval_type=="TargetValues") dplyr::filter(., modelname == select_model & dataset == select_dataset)%>%
        dplyr::mutate(.,lines=category)
    else print('no valid evaluation type specified!')}
  eval_t_type <<- cbind(eval_type=eval_type,
                        eval_t_type)
return('Data preparation step 2 succeeded! Dataframe \'eval_t_tot\' created.')

}
