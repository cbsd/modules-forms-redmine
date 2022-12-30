# Linux required -i'', not "-i ''" for inplace
os=$( uname -s )
case "${os}" in
	Linux)
		# Linux require -i'', not -i ' '
		sed_delimer=
		;;
	FreeBSD)
		sed_delimer=" "
		;;
esac

generate_manifest()
{
cat <<EOF
  class { 'timezone': }
  class { 'loginconf': }
  class { 'mailalias': }
  class { 'profiles::db::mysql': }
  class { 'redmine': }
EOF
}

generate_hieradata()
{
	local my_common_yaml="${my_module_dir}/common.yaml"
	local _val _tpl

	if [ -f "${my_common_yaml}" ]; then
		local tmp_common_yaml=$( mktemp )
		trap "/bin/rm -f ${tmp_common_yaml}" HUP INT ABRT BUS TERM EXIT
		/bin/cp ${my_common_yaml} ${tmp_common_yaml}
		for i in ${param}; do
			case "${i}" in
				-*)
					# delimier params
					continue
					;;
				Expand)
					# delimier params
					continue
					;;
			esac

			eval _val=\${${i}}
			_tpl="#${i}#"
			# Note that on Linux systems, a space after -i might cause an error
			sed -i${sed_delimer}'' -Ees:"${_tpl}":"${_val}":g ${tmp_common_yaml}
		done
		cat ${tmp_common_yaml}
	else
		for i in ${param}; do
			eval _val=\${${i}}
		cat <<EOF
 $i: "${_val}"
EOF
		done
	fi
}
