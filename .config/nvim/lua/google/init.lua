return {
  In_ct = function()
    return os.execute '[[ $OSTYPE == linux-gnu* ]] && command -v gcert' == 0
  end,
}
