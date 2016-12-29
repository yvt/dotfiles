#template add_path_no_check(p)
add_path %{escape(p)}
#end template

#template add_path_weak_no_check(p)
add_path_weak %{escape(p)}
#end template

#template replace_env(name, old_term, new_term)
if [ "$%name" == %{escape(old_term)} ]; then
    export %name=%{escape(new_term)}
fi
#end template

#template set_env_if_not_in(name, old_term, new_term)
if %{" && ".join(('[ "$' + name + '" == ' + escape(t) + ' ]' for t in old_term))}; then
    export %name=%{escape(new_term)}
fi
#end template

#template define_abbr(name, cmd)
alias %name=%{escape(cmd)}
#end template

#* FIXME: this is not safe
#template escape(string)
'%string'%>
#end template