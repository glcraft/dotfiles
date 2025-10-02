export def load-wiitdb [path:string]: nothing -> nothing {
    if (stor open | query db "SELECT name FROM sqlite_schema " | where name == wiitdb | is-empty) {
        stor create --table-name wiitdb --columns {longname:str name:str region:str gameid:str} | ignore
    }

    open $path | get content | where tag == game | each {|game|
        {
            longname: $game.attributes.name
            name:($game.content | where {$in.tag == locale and $in.attributes.lang == EN} | get 0.content | where tag == title | get 0.content.0.content)
            region: ($game.content | where tag == region | get -i 0.content.0.content | default "")
            gameid: ($game.content | where tag == id | get 0.content.0.content)
        } | stor insert --table-name wiitdb
    }  | ignore
}

