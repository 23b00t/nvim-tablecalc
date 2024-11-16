local config = {
  -- Set the delimiter used for tables (e.g., '|' for pipe-separated tables)
  delimiter = '|',
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
