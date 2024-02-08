--
-- Licensed to the Apache Software Foundation (ASF) under one or more
-- contributor license agreements.  See the NOTICE file distributed with
-- this work for additional information regarding copyright ownership.
-- The ASF licenses this file to You under the Apache License, Version 2.0
-- (the "License"); you may not use this file except in compliance with
-- the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
local redis_cluster     = require("apisix.utils.rediscluster")
local setmetatable      = setmetatable
local util              = require("apisix.plugins.limit-req.util")

local _M = {version = 0.1}


local mt = {
    __index = _M
}


function _M.new(plugin_name, conf, rate, burst)
    local red_cli, err = redis_cluster.new(conf, "plugin-limit-req-redis-cluster-slot-lock")
    if not red_cli then
        return nil, err
    end
    local self = {
        conf = conf,
        plugin_name = plugin_name,
        burst = burst * 1000,
        rate = rate * 1000,
        red_cli = red_cli,
    }
    return setmetatable(self, mt)
end


-- the "commit" argument controls whether should we record the event in shm.
function _M.incoming(self, key, commit)
    return util.incoming(self, self.red_cli, key, commit)
end


return _M
