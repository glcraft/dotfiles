export def repeat [
    text: string 
    count: int
] {
    (0..<$count | each {|| $text} | str join)
}

export-env {
    let-env MARKDOWN_THEME = {
        code: "93"
        link: "36"
        title: "107;90"
        prompt: "32"
        bold_italic: "1;3"
        bold: "1"
        italic: "3"
    }
}

def md_title [title: string] {
    let size = ((term size | get columns)) - 4
    let title_length = ($title | str length)
    let left = (($size / 2) - $title_length / 2)
    let right = ($size - $left - $title_length)
    let line = (char -u "2500")
    let line_stop_left = (char -u "2574")
    let line_stop_right = (char -u "2576")
    print $"\n(1..$left | each {|| $line } | str join)($line_stop_left)(ansi -e { fg: '#000000' bg: '#ffffff' attr: b }) ($title) (ansi reset)($line_stop_right)(1..$right | each {|| $line } | str join)\n"
}

export def "parse advanced" [
    pattern: string
    reconstruct: closure
    --regex(-r)
] {
    let input = $in
    let parsed = ($input | if $regex {parse -r $pattern} else {parse $pattern})
    mut list_result = []
    mut previous = 0
    if ($parsed | length) > 0 {
        for $i in 0..<($parsed | length) {
            let current = ($parsed | get $i)
            let reconstructed = (do $reconstruct $current)
            let begin = ($input | str index-of -r $"($previous)," $reconstructed)
            let end = ($begin + ($reconstructed | str length))
            $list_result = ($list_result | append ($current | merge {
                begin: $begin
                end: $end
                reconstructed: $reconstructed
            }))
            $previous = $end
        }
    }
    $list_result
}
def md_add_modifier [
    previous_modifier?: list
] {
    let text = $in
    mut text = $text
    let append_modifier = { |mod| ansi -e $'($previous_modifier | append [$mod] | str join ";")m'}
    let apply_prev_mod = (if $previous_modifier == null {ansi reset} else {[(ansi reset) (ansi -e $'($previous_modifier | str join ";")m')] | str join})
    if $text =~ '\[[^\]]+\]\([^)]+\)' {
        let captured_data = ($text | parse -r '\[(?<text>[^\]]+)\]\((?<url>[^)]+)\)')
        if ($captured_data | length) > 0 {
            for $i in 0..<($captured_data | length) {
                let current = ($captured_data | get $i)
                let captured = $"[($current.text)]\(($current.url)\)"
                $text = ($text | str replace -s $captured $"(do $append_modifier $env.MARKDOWN_THEME.link)($current.url | ansi link --text $current.text)($apply_prev_mod)")
            }
        }
    }
    if ($text =~ '`[^`]+`') {
        $text = ($text | str replace "`([^`]+)`" $"(do $append_modifier $env.MARKDOWN_THEME.code)$1($apply_prev_mod)")
    }
    if ($text =~ '\*\*\*(?:(?!\*\*\*).)+\*\*\*') {
        let parsed = ($text | parse -r '\*\*\*(?<text>(?:(?!\*\*\*).)+)\*\*\*')
        if ($parsed | length) > 0 {
            for $i in 0..<($parsed | length) {
                let current = ($parsed | get $i)
                let captured = $"***($current.text)***"
                $text = ($text | str replace -s $captured $"(do $append_modifier $env.MARKDOWN_THEME.bold_italic)($current.text | md_add_modifier ($previous_modifier | append [$env.MARKDOWN_THEME.bold_italic]))($apply_prev_mod)")
            }
        }
    }
    if ($text =~ '\*\*(?:(?!\*\*).)+\*\*') {
        let parsed = ($text | parse -r '\*\*(?<text>(?:(?!\*\*).)+)\*\*')
        if ($parsed | length) > 0 {
            for $i in 0..<($parsed | length) {
                let current = ($parsed | get $i)
                let captured = $"**($current.text)**"
                $text = ($text | str replace -s $captured $"(do $append_modifier $env.MARKDOWN_THEME.bold)($current.text | md_add_modifier ($previous_modifier | append [$env.MARKDOWN_THEME.bold]))($apply_prev_mod)")
            }
        }
    }
    if ($text =~ '\*[^*]+\*') {
        let parsed = ($text | parse -r '\*(?<text>[^*]+)\*')
        if ($parsed | length) > 0 {
            for $i in 0..<($parsed | length) {
                let current = ($parsed | get $i)
                let captured = $"*($current.text)*"
                $text = ($text | str replace -s $captured $"(do $append_modifier $env.MARKDOWN_THEME.italic)($current.text | md_add_modifier ($previous_modifier | append [$env.MARKDOWN_THEME.italic]))($apply_prev_mod)")
            }
        }
    }
    $text
}

export def "display markdown" [
    input: string
    --no-bat(-b)
    --force-nu
] {
    mut markdown = $input
    mut code_lang = ""
    mut code = []
    mut is_code = false
    for $line in ($markdown | lines) {
        
        if ($line =~ "^```") {
            if $is_code == true {
                let str_code = ($code | str join "\n")
                let bat = (which bat)
                if ($bat | length) > 0 and (not $no_bat) {
                    mut bat_args = [--color always --paging never --file-name $"code ($code_lang)" -]
                    
                    if ($code_lang | is-empty) == false  and $code_lang != "nu" {
                        $bat_args = ($bat_args | append ["--language" $code_lang])
                    }
                    if $code_lang == "nu" {
                        $str_code | nu-highlight | bat $bat_args
                    } else {
                        $str_code | bat $bat_args
                    }
                    
                } else {
                    if $code_lang == "nu" or $force_nu {
                        $str_code | nu-highlight | print
                    } else {
                        print $str_code
                    }
                }
                $code = []
                $code_lang = ""
                $is_code = false
            } else {
                let langs = ($line | parse -r '^```(?<lang>\w+)')
                $code_lang = (if ($langs | length) > 0 {($langs | get 0.lang)} else {null})
                $code = []
                $is_code = true
            }
            continue
        } 
        if $is_code == true {
            $code = ($code | append [$line])
            continue
        }

        if ($line =~ '^\s*#+\s+') {
            let name = ($line | parse -r '^\s*#+\s+(?<name>.*)$' | get 0.name)
            md_title $name
            continue
        } 

        mut newline = $line
        
        if ($newline =~ '^\s*-\s+') {
            let parsed = ($line | parse -r '^(\s*)(-\s+)' | get 0 )
            let index = (($parsed.capture0 | str length) + ($parsed.capture1 | str length))
            let spacing = ($parsed.capture0 | str length)
            $newline = $"(repeat ' ' $spacing)(char prompt) ($newline | str substring $index..)"
        }

        $newline = ($newline | md_add_modifier)
        print $newline
        print -n (ansi reset)
    }
}