using Turing
using DataFrames
using Random: seed!

seed!(123)

# simulated data
real_p = 0.75
y = rand(Bernoulli(real_p), 1_000)

# simple model for biased coin flips
@model function coin_flip(y)
    # prior
    p ~ Beta(1, 1)

    # likelihood
    for i in eachindex(y)
        y[i] ~ Bernoulli(p)
    end
    return (; p, y)
end

# Instantiate the model
model = coin_flip(y)

# Prior Predictive Check
# Step 1: Get the draws for the priors only.
# i.e. don't condition on data.
# Just use the Prior() sampler:
prior_chain = sample(model, Prior(), 2_000)
println(DataFrame(summarystats(prior_chain)))

# Step 2: Instantiate a Vector of missing values
# with the same dimensions as y:
y_missing = similar(y, Missing)

# Step 3: Instantiate the model with the
# Vector of missing values:
model_missing = coin_flip(y_missing)

# Step 4: Predict for your model with missing values
# using the draws from the prior only:
prior_check = predict(model_missing, prior_chain)

# Posterior Predictive Check
# Step 1: Get the draws for the full model.
# i.e. do condition on data.
# Just use any sampler except the Prior():
posterior_chain = sample(model, MH(), 2_000)
println(DataFrame(summarystats(posterior_chain)))

# Step 2: Instantiate a Vector of missing values
# with the same dimensions as y:
y_missing = similar(y, Missing)

# Step 3: Instantiate the model with the
# Vector of missing values:
model_missing = coin_flip(y_missing)

# Step 4: Predict for your model with missing values
# using the draws from the full model:
posterior_check = predict(model_missing, posterior_chain)
