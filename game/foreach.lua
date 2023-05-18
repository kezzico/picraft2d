function forEach(table_1dex, callback)
	for i=1, #table_1dex do
		callback(table_1dex[i])
	end
end

function forEachPair(table_pairs, action)
  for key in pairs(table_pairs) do
    local t = table_pairs[key]

    action(t)
  end
end
