# encoding: UTF-8

# これつけないと動かないけど、出来るだけメイン部分とは離したい
# それぞれの環境に適当に合わせてください
def command cmd
	`powershell #{cmd}`
end

# コマンド群
module Cmd extend self
	# 処理の流れにコマンドと省略コマンドを入れる
	# 戻り値に、そのコマンドを実行したかどうかが入る
	def sync commands
		commands_base("sync", "s", commands, [])
	end
	def delete_branch commands, target
		commands_base("branch -D", "d", commands, [target])
	end
	def merge commands, target
		commands_base("merge --no-ff", "m", commands, [target])
	end
	def merge_ff commands, target
		commands_base("merge --ff", "mf", commands, [target])
	end
	def merge_squash commands, target
		commands_base("merge --squash", "ms", commands, [target])
	end
	def checkout commands, target
		commands_base("checkout", "c", commands, [target])
	end
	def new_branch commands, target
		commands_base("checkout -b", "nb", commands, [target])
	end
	
	private
	# コマンドがあっていた場合、その分を削り、コマンドを実行する
	def commands_base name, abbreviation_command, commands, argument
		# nilはshiftでの要素が足りないときの戻り値
		abort "ターゲットが足りません。コマンド:'#{name}' 省略コマンド:'#{abbreviation_command}' ターゲット:'#{argument}'" if argument.include?(nil)
		abbcom_len = abbreviation_command.length
		if commands.take(abbcom_len).join("")==abbreviation_command
			commands.shift(abbcom_len)
			exec_command(name, argument)
			return true
		end
		return false
	end
	#
	def exec_command name, argument
		exe_shell = "git #{name} #{argument.join(" ")}"
		puts "\n"+exe_shell
		puts "\t"+command(exe_shell)
		return_num = $?.to_i
		abort "#{name}に失敗しました。" unless return_num==0
	end
end

def current_branch
	command("git rev-parse --abbrev-ref HEAD").chomp
end

# この関数群を動き回って処理していく
def start commands, targets
	while commands.length > 0
		case
		when commands[0..1].join("") == "nb" || commands[0] == "c"
			start_branch = current_branch
			target_branch = targets.shift
			# どちらか一方だけ実行するため
			Cmd.new_branch(commands, target_branch) || Cmd.checkout(commands, target_branch)
			checkout_after(commands, start_branch)
		when commands[0] == "m"
			merges(commands, targets)
		when commands[0] == "s"
			Cmd.sync(commands)
		when commands[0] == "d"
			Cmd.delete_branch(commands, targets.shift)
		when commands[0] == "-"
			commands.shift
		else
			abort "コマンドが不明です'#{commands.join}'"
		end
	end
	"処理が終了した際にターゲットが残っています。'#{targets}'" if targets.length > 0
end
# チェックアウトの後などに、チェックアウト前に対してターゲットを省略するもの
def checkout_after commands, start_branch
	merge3(commands, start_branch)
	Cmd.delete_branch(commands, start_branch)
	Cmd.checkout(commands, start_branch) # どちらかしかできないが、どうせエラーでわかるのでそのまま
end
# マージの際、マージ先に対してのコマンドで、ターゲットを省略するもの
# 戻り値に、ブランチを削除したかどうかを返す
def merges commands, targets
	merge_target = targets.shift
	
	merge3(commands, merge_target)
	Cmd.delete_branch(commands, merge_targets)
end
# 三種類のマージを試す。
def merge3 commands, target
	Cmd.merge_ff(commands, target)
	Cmd.merge_squash(commands, target)
	Cmd.merge(commands, target)
end

# 起動用
commands = ARGV.shift.split("")
start(commands, ARGV)
