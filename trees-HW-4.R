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

## (b)
pred.boost <- predict(ems.boost, newdata=test, n.trees=2000)
ems.boost.test.mse <- mean((pred.boost - test$response_time)^2)





