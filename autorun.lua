local function xpcall_wrap(func)
	return function()
		xpcall(func, function(err)
			print(err)
			print(debug.traceback())
			os.exit(1)
		end)
	end
end

xpcall_wrap(function()
	local suites = {
		screenfuls = {
			dust = { path = "suites/screenfuls/dust.cps", duration = 100 },
		},
	}

	local warmup_passes = 1
	local measurement_passes = 5
	local benchmark_requests = {
		"screenfuls/dust",
	}

	local function print(msg)
		io.stdout:write(msg)
		io.stdout:write("\n")
	end

	local function eq_print(level, msg)
		print(("%s %s"):format(("#"):rep(level), msg))
	end

	local function next_frame()
		coroutine.yield()
	end

	local function summarize(measurements)
		local mean_sum = 0
		for _, measurement in ipairs(measurements) do
			mean_sum = mean_sum + measurement.frame_time
		end
		local mean = mean_sum / #measurements
		local var_sum = 0
		for _, measurement in ipairs(measurements) do
			var_sum = var_sum + (mean - measurement.frame_time) ^ 2
		end
		local var = (var_sum / (#measurements - 1)) ^ 0.5
		eq_print(2, ("frame time: %.2fus (%.2ffps), stddev %.2fus"):format(mean * 1e6, 1 / mean, var * 1e6))
	end

	local function pass(benchmark)
		sim.clearSim()
		sim.loadStamp(benchmark.path, 0, 0)
		local t0 = socket.gettime()
		for i = 1, benchmark.duration do
			next_frame()
		end
		local t1 = socket.gettime()
		return {
			frame_time = (t1 - t0) / benchmark.duration,
		}
	end

	local function bench()
		for _, benchmark_request in ipairs(benchmark_requests) do
			local suite, name = benchmark_request:match("^([^/]+)/([^/]+)$")
			eq_print(1, ("benchmark %s/%s"):format(suite, name))
			local benchmark = suites[suite][name]
			for ix_warmup = 1, warmup_passes do
				eq_print(2, ("warmup pass #%i"):format(ix_warmup))
				pass(benchmark)
			end
			local measurements = {}
			for ix_measurement = 1, measurement_passes do
				eq_print(2, ("measurement pass #%i"):format(ix_measurement))
				table.insert(measurements, pass(benchmark))
			end
			summarize(measurements)
		end
		os.exit(0)
	end

	local co = coroutine.create(xpcall_wrap(bench))
	event.register(event.TICK, function()
		coroutine.resume(co)
	end)
end)()
