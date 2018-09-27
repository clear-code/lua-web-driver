local Searchable = {}

function Searchable:css_select(selectors)
  return self:find_elements("css selector", selectors)
end

function Searchable:xpath_search(xpath)
  return self:find_elements("xpath", xpath)
end

-- For XMLua compatibility
Searchable.search = Searchable.xpath_search

function Searchable:link_search(text)
  return self:find_elements("link text", text)
end

function Searchable:partial_link_search(substring)
  return self:find_elements("partial link text", substring)
end

function Searchable:tag_search(name)
  return self:find_elements("tag name", name)
end

return Searchable
