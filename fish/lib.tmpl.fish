#template add_path_no_check(p)
add_path %{escape(p)}
#end template

#template replace_env(name, old_term, new_term)
test $%name = %{escape(old_term)}
  and set -x %name %{escape(new_term)}
#end template

#template set_env_if_not_in(name, old_term, new_term)
not contains $%name %{" ".join((escape(t) for t in old_term))}
  and set -x %name %{escape(new_term)}
#end template

#template define_abbr(name, cmd)
abbr %name %cmd
#end template

#* FIXME: this is not safe
#template escape(string)
"%string"%>
#end template