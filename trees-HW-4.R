set.seed(423)

ems <- clean_names(emergency_response_data)

train_idx <- sample(1:nrow(ems), 0.8 * nrow(ems))
train <- ems[train_idx, ]
test  <- ems[-train_idx, ]

train[] <- lapply(train, function(x) {
  if (is.character(x)) as.factor(x) else x
})

test[] <- lapply(test, function(x) {
  if (is.character(x)) as.factor(x) else x
})

# full tree
ems.tree.full <- tree(
  response_time ~ call_final_disposition + city + priority +
    number_of_alarms + fire_prevention_district +
    medical_als + medical_bls + fire_response +
    command + support + hour + day_of_week,
  data = train,
  mindev = 0.001
)

# prune, get mse
ems.cv <- cv.tree(ems.tree.full, K=5)
best.size <- min(ems.cv$size[ems.cv$dev == min(ems.cv$dev)])

ems.tree.pruned <- prune.tree(ems.tree.full, best=best.size)

pred.cv <- predict(ems.tree.pruned, newdata = test)
ems.tree.test.mse <- mean((test$response_time - pred.cv)^2)

# full tree mse
pred.cv.full <- predict(ems.tree.full, newdata = test)
ems.tree.full.test.mse <- mean((test$response_time - pred.cv.full)^2)

# try boosting
ems.boost <- gbm(response_time ~ call_final_disposition + city + priority +
                   number_of_alarms + fire_prevention_district +
                   medical_als + medical_bls + fire_response +
                   command + support + hour + day_of_week + neighborhooods_analysis_boundaries + call_type, data=train,
                    distribution="gaussian",
                    n.trees = 2000, # B
                    interaction.depth = 2, # d
                    shrinkage = 0.3 # lambda
)

pred.boost <- predict(ems.boost, newdata=test, n.trees=2000)
ems.boost.test.mse <- mean((pred.boost - test$response_time)^2)

## try classification
# < 10 mins and >= 10 mins
# 188404 are < 10, 164666 are >= 10, roughly balanced
# < 10 mins 90% of the time is the SF policy goal

train$response_class <- factor(ifelse(train$response_time < 10, "fast", "slow"))
test$response_class  <- factor(ifelse(test$response_time < 10, "fast", "slow"))

ems.tree.class <- tree(
  response_class ~ call_final_disposition + city + priority +
    number_of_alarms + fire_prevention_district +
    medical_als + medical_bls + fire_response +
    command + support + hour + day_of_week,
  data = train,
  mindev = 0.001
)

# prune, get mse
ems.cv.class <- cv.tree(ems.tree.class, K=5)
best.size.class <- min(ems.cv.class$size[ems.cv.class$dev == min(ems.cv.class$dev)])

ems.tree.class.pruned <- prune.tree(ems.tree.class, best=best.size.class)

pred.cv.class <- predict(ems.tree.class.pruned, newdata = test, type="class")
misclass.rate <- mean(pred.cv.class != test$response_class)
# 19% error rate

train$response_class <- ifelse(train$response_time < 10, 1,0)
test$response_class  <- ifelse(test$response_time < 10, 1,0)

## try boosting with classification
ems.boost.class <- gbm(
  response_class ~ call_final_disposition + city + priority +
    number_of_alarms + fire_prevention_district +
    medical_als + medical_bls + fire_response +
    command + support + hour + day_of_week,
  data = train,
  distribution = "bernoulli",
  n.trees = 2000,
  interaction.depth = 2,
  shrinkage = 0.05
)

pred.prob <- predict(ems.boost.class, newdata = test, n.trees = 2000, type = "response")
pred.class <- ifelse(pred.prob > 0.5, 1, 0)
misclass.rate.boost <- mean(pred.class != test$response_class)
# 18.5% error rate



