# gt
gitのブランチ操作をまとめた感じのやつ。

### コマンド例

`gt cmds master`
masterブランチにカレントブランチをマージして、マージしたブランチを削除。そしてそのままsyncする。

`gt cmc aaa`
aaaブランチにカレントブランチをマージして、戻る。

`gt mfd aaa`
aaaブランチをfast-forwardでマージし、aaaブランチを削除する。

`gt s`
syncのみ。

### その他
できるだけ自分に使い心地のいい仕様を目指しているので、一部変な点もあるかもしれないです。

ブランチの削除は-Dで行うので、気をつけてください。
