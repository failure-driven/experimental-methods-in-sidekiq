# Experimental Methods in Sidekiq

Experimental methods to play around with jobs and sidekiq

## Presentation

```
make
make install
make present
```

## Basic long running job

```
make setup
make demo-basic

make demo-long-job duration=10 # 10 second long job
```

## Run and monitor sidekiq

in seprate windows

```
make sidekiq
make sidekiq-web
watch --interval 1 make db-show

make view-sidekiq-web
# open http://localhost:9292

make db-reset
```

## Demo sidekiq

```
make demo-sidekiq

make create-user name=mike

# fail_job_1: "PART 1 killer"
make create-user name=kevin

# fail_job_2: "die in part 2"
make create-user name=matt
```

## Demo sidekiq Outbox

```
make demo-sidekiq

make outbox-create-user name=mike

# fail_job_1: "PART 1 killer"
make outbox-create-user name=kevin

# fail_job_2: "die in part 2"
make outbox-create-user name=matt
```

## Run and monitor que

in seprate windows

```
make que
# FAILS
#   bundle exec que
#   wrong number of arguments (given 1, expected 0)

make que-web
watch --interval 1 make db-show-que

make view-que-web
# open http://localhost:9292

make db-reset
```

## Clean up

```
make clean
```
