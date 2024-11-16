local config = {
  -- Set the delimiter used for tables (e.g., '|' for pipe-separated tables)
  delimiter = '|',
  formula_begin = '{',
  formula_end = '}',
  table_name_marker = '#',
  filetype = 'org',
  commands = {
    org = 'normal gggqG',
    -- TODO: md = '',
    -- csv?
  }
}

function config.get_command()
    return config.commands[config.filetype] or error("Invalid filetype in config")
end

return config
