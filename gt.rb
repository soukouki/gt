# encoding: UTF-8

def command command_name, argument
	abort "#{command_name}の引数がありません。" if argument.include?(nil)
	# Array#shiftなどは、要素が無いときはnilを返すのでそれを見つける
	puts `git #{command_name} #{argument.join(" ")}`
	return_num = $?.to_i
	abort "#{command_name}に失敗しました。" unless return_num==0
end

def sync input
	if input[0]=="s"
		input.shift
		command "sync", []
	end
end

def delete_branch input, target
	if input[0]=="d"
		input.shift
		command "branch -D", [target]
	end
end

def merge input, target
	if input[0]=="m"
		input.shift
		command "merge", [target]
	end
end

def checkout input, terget, should_see_diff_commit
	if input[0]=="c"
		input.shift
		start_branch = current_branch if should_see_diff_commit
		command "checkout", [terget]
		puts `git l1 #{start_branch}..#{current_branch}` if should_see_diff_commit
	end
end

def current_branch
	`git rev-parse --abbrev-ref HEAD`
end

input = ARGV.shift.split("")

if input[0]=="c"
	start_branch = current_branch
	checkout(input, ARGV.shift, true)

	merge(input, start_branch)

	delete_branch input, start_branch

	sync input

	checkout(input, start_branch, false)
elsif input[0]=="m"
	merge_target = ARGV.shift
	merge(input, merge_target)

	delete_branch(input, merge_target)
elsif input[0]=="d"
	delete_branch(input, ARGV.shift)
end

sync input
