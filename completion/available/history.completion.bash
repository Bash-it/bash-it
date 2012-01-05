if [ -n "$PS1" ]; then
  bind '"\C-[[A": history-search-backward'
  bind '"\C-[[B": history-search-forward'
fi