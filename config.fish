set -Ux LSCOLORS gxfxbEaEBxxEhEhBaDaCaD

# no greeting, please
set fish_greeting

set -g fish_prompt_pwd_dir_length 0

# AWS
set -x AWS_ACCESS_KEY_ID <access key>
set -x AWS_SECRET_ACCESS_KEY <secret key>

set -x KOPS_STATE_STORE s3://<bucket>
set -x AWS_PROFILE <profile>

# GCP
set -x GCP_AUTH_KIND serviceaccount
set -x GCP_SERVICE_ACCOUNT_FILE <JSON path>

# Python
set -x WORKON_HOME $HOME/.virtualenvs

function custom_prompt
    set_color normal
    set -l git_branch (git branch 2>/dev/null | sed -n '/\* /s///p')
	set -l kube_context (kubectl config current-context | cut -d. -f1)
	set_color 2eb82e
    set_color cyan
    echo -n (prompt_pwd)
    set_color normal
    echo -n ' ['
    set_color 0087ff
    echo -n "$git_branch"
	if [ ! -z "$git_branch" ]
	  set_color normal
	  echo -n "/"
	end
	set_color 00b386
	echo -n "$kube_context"
    set_color normal
    echo -n ']'
	set_color cyan
    echo -n '$ '
end

function fish_prompt --description "Custom fish prompt"
	custom_prompt
end

function show --description "Show fish prompt"
	function fish_prompt
		custom_prompt
	end
end

function hide --description "Hide fish prompt"
	function fish_prompt
      echo -n '> '
    end
end

if status --is-interactive
	# bash abbr
	abbr -a -g sfish source ~/.config/fish/config.fish
	abbr -a -g nowdate date +"%d-%m-%Y"
	function mcd
		mkdir -p $argv[1]
		cd $argv[1]
	end

    # K8s abbr
    set -gx PATH $PATH $HOME/.krew/bin
    alias devkub "kubectl config use-context dev-context.com"
    alias qakube "kubectl config use-context qa-context.com"
	abbr -a -g flushredis "kubectl get pods -l app=redis -o=name | sed \"s/^.{4}//\" | xargs -I{} sh -c \"kubectl exec {} redis-cli flushall\""

	function exec-some-pod
		set id_pod (kubectl get pods -l app=som-app -o custom-columns=":metadata.name" | grep .)
    	kubectl exec -it "$id_pod" bash
	end

	function log-some-pod
		set id_pod (kubectl get pods -l app=some-pod -o custom-columns=":metadata.name" | grep .)
    	kubectl logs -f "$id_pod"
	end

	function current_image
		set image (kubectl get deployment some-pod -o=jsonpath='{$.spec.template.spec.containers[:1].image}')
		printf "$image\n"
	end

    # Docker abbr
    alias rmidang 'docker rmi -f (docker images -f "dangling=true" -q)'
	abbr -a -g dri docker images
	abbr -a -g clear_rabbit 'docker ps | grep rabbit | awk \'{ print $1 }\' | xargs -I{}  docker exec {} bash -c "rabbitmqctl stop_app ; rabbitmqctl reset ; rabbitmqctl start_app"'

	# MySQL
	alias dev_mysql "mycli -hdev-sql -uroot -p<pass>"
	alias qa_mysql "mycli -hqa.sql -uroot -p<pass>"

	# Jenkins
	alias jenkins_dev "ssh -i ~/.ssh/<pem> ubuntu@<ip>"

	# Python
	alias python "/usr/local/bin/python3"

	# Passwords
	alias generate_pass "openssl rand -base64 10"
end

# the fuck
thefuck --alias | source

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/<path>/google-cloud-sdk/path.fish.inc' ]; . '<path>/google-cloud-sdk/path.fish.inc'; end
