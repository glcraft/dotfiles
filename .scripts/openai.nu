#!/usr/bin/env nu

# MIT LICENCE
#
# Copyright 2023 Gabin Lefranc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.

def get-api [] {
    if not "OPENAI_API_KEY" in $env {
        error make {msg: "OPENAI_API_KEY not set"}
        exit 1
    }
    return $env.OPENAI_API_KEY
}
# Lists the OpenAI models
export def models [
    --model: string    # The model to retrieve
] {
    let suffix = (if $model == null or $model == "" {
        ""
    } else {
        $"/($model)"
    })
    http get $"https://api.openai.com/v1/models($suffix)" -H ["Authorization" $"Bearer (get-api)"]
}
# Helper function to add a parameter to a record if it's not null.
def add_param [name: string, value: any] {
    merge (if $value != null {
        { $name: $value }
    } else {
        {}
    })
}
# Chat completion API call. 
export def "api chat-completion" [
    model: string                   # ID of the model to use.
    messages: list                 # List of messages to complete from.
    --max-tokens: int               # The maximum number of tokens to generate in the completion.
    --temperature: number           # The temperature used to control the randomness of the completion.
    --top-p: number                 # The top-p used to control the randomness of the completion.
    --n: int                        # How many completions to generate for each prompt. Use carefully, as it's a token eater.
    --stop: any                     # Up to 4 sequences where the API will stop generating further tokens.
    --frequency-penalty: number     # A penalty to apply to each token that appears more than once in the completion.
    --presence-penalty: number      # A penalty to apply if the specified tokens don't appear in the completion.
    --logit-bias: record            # A record to modify the likelihood of specified tokens appearing in the completion
    --user: string                  # A unique identifier representing your end-user.
] {
    # See https://platform.openai.com/docs/api-reference/chat/create
    let params = ({ model: $model, messages: $messages } 
        | add_param "max_tokens" $max_tokens
        | add_param "temperature" $temperature
        | add_param "top_p" $top_p
        | add_param "n" $n
        | add_param "stop" $stop
        | add_param "frequency_penalty" $frequency_penalty
        | add_param "presence_penalty" $presence_penalty
        | add_param "logit_bias" $logit_bias
        | add_param "user" $user
    )
    let result = (http post "https://api.openai.com/v1/chat/completions" -H ["Authorization" $"Bearer (get-api)"] -t 'application/json' $params)
    # print ($params | to json)
    # let result = ""
    $result
}
# Completion API call. 
export def "api completion" [
    model: string                   # ID of the model to use.
    --prompt: string                # The prompt(s) to generate completions for
    --suffix: string                # The suffix that comes after a completion of inserted text.
    --max-tokens: int               # The maximum number of tokens to generate in the completion.
    --temperature: number           # The temperature used to control the randomness of the completion.
    --top-p: number                 # The top-p used to control the randomness of the completion.
    --n: int                        # How many completions to generate for each prompt. Use carefully, as it's a token eater.
    --logprobs: int                 # Include the log probabilities on the logprobs most likely tokens, as well the chosen tokens.
    --echo: bool                    # Include the prompt in the returned text.
    --stop: any                     # A list of tokens that, if encountered, will stop the completion.
    --frequency-penalty: number     # A penalty to apply to each token that appears more than once in the completion.
    --presence-penalty: number      # A penalty to apply if the specified tokens don't appear in the completion.
    --best-of: int                  # Generates best_of completions server-side and returns the "best" (the one with the highest log probability per token). Use carefully, as it's a token eater.
    --logit-bias: record            # A record to modify the likelihood of specified tokens appearing in the completion
    --user: string                  # A unique identifier representing your end-user.
] {
    # See https://platform.openai.com/docs/api-reference/completions/create
    let params = ({ model: $model } 
        | add_param "prompt" $prompt
        | add_param "suffix" $suffix
        | add_param "max_tokens" $max_tokens
        | add_param "temperature" $temperature
        | add_param "top_p" $top_p
        | add_param "n" $n
        | add_param "logprobs" $logprobs
        | add_param "echo" $echo
        | add_param "stop" $stop
        | add_param "frequency_penalty" $frequency_penalty
        | add_param "presence_penalty" $presence_penalty
        | add_param "best_of" $best_of
        | add_param "logit_bias" $logit_bias
        | add_param "user" $user
    )
    let result = (http post "https://api.openai.com/v1/completions" -H ["Authorization" $"Bearer (get-api)"] -t 'application/json' $params)
    # let params = ($params | merge {prompt: $"($params.prompt)($result.choices.0.text)"})
    # export-env {
    #     let-env openai = {
    #         previous: {
    #             parameters: $params
    #             url: "https://api.openai.com/v1/completions"
    #         }
    #     }
    # }
    $result
}
def md_title [title: string] {
    let size = ((term size | get columns) / 2) - 4
    let title_length = ($title | str length)
    let left = (($size / 2) - $title_length / 2)
    let right = ($size - $left - $title_length)
    let line = (char -u "2500")
    let line_stop_left = (char -u "2574")
    let line_stop_right = (char -u "2576")
    print $"\n(1..$left | each {|| $line } | str join)($line_stop_left)(ansi -e { fg: '#000000' bg: '#ffffff' attr: b }) ($title) (ansi reset)($line_stop_right)(1..$right | each {|| $line } | str join)\n"
}
def md_to_console [md: string] {
    mut is_code = false
    for $line in ($md | lines) {
        if ($line =~ "^\\s*```") {
            $is_code = (not $is_code)
            continue
        } 
        if $is_code {
            $line | nu-highlight | print
            continue
        }
        mut index = 0
        if ($line =~ '^\s*#+\s+') {
            let name = ($line | parse -r '^\s*#+\s+(?<name>.*)$' | get 0.name)
            # print $"\n(ansi -e { fg: '#000000' bg: '#ffffff' attr: b }) ($name) (ansi reset)\n"
            md_title $name
            continue
        } else if ($line =~ '^\s*-\s+') {
            print -n $"(char prompt) "
            $index = ($line | parse -r '^(\s*-\s+)' | get 0.capture0 | str length)
        }
        mut is_inline_code = false
        for $char in ($line | split chars | skip $index) {
            if $char == '`' {
                print -n (if not $is_inline_code {ansi yellow} else {ansi reset})
                $is_inline_code = (not $is_inline_code)
            } else {
                print -n $char
            }
        }
        print (ansi reset)
    }
}
# Ask for a command to run. Will return one line command.
export def command [
    input?: string      # The command to run. If not provided, will use the input from the pipeline
    --max-tokens: int   # The maximum number of tokens to generate, defaults to 64
    --no-interactive    # If true, will not ask to execute and will pipe the result 
] {
    let input = ($in | default $input)
    if $input == null {
        error make {msg: "input is required"}
    }
    let max_tokens = ($max_tokens | default 200)
    let messages = [
        {"role": "system", "content": "You are a command line analyzer. Write the command that best fits my request in a \"Command\" markdown chapter then describe each parameter used in a \"Explanation\" markdown chapter."},
        {"role": "user", "content": $input}
    ]
    let result = (api chat-completion "gpt-3.5-turbo" $messages --temperature 0 --top-p 1.0 --frequency-penalty 0.2 --presence-penalty 0 --max-tokens $max_tokens  )
    # return $result
    let result = $result.choices.0.message.content
    md_to_console $result
    
    if not $no_interactive {
        print ""
        if (input "Execute ? (y/n) ") == "y" {
            nu -c $"($result)"
        }
    }
}
# Ask any question to the OpenAI model.
export def ask [
    input?: string                          # The question to ask. If not provided, will use the input from the pipeline
    --model: string = "gpt-3.5-turbo"    # The model to use, defaults to text-davinci-003
    --max-tokens: int                       # The maximum number of tokens to generate, defaults to 150
] {
    let input = ($in | default $input)
    if $input == null {
        error make {msg: "input is required"}
    }
    if ($input | describe) != "string" {
        error make {msg: "input must be a string"}
    }
    let max_tokens = ($max_tokens | default 300)
    let messages = [
        {"role": "system", "content": "You are GPT-3.5, answer my question as if you were an expert in the field."},
        {"role": "user", "content": $input}
    ]
    let result = (api chat-completion $model $messages --temperature 0.7 --top-p 1.0 --frequency-penalty 0 --presence-penalty 0 --max-tokens $max_tokens )
    $result.choices.0.message.content | str trim
}

export def "git diff" [
    --max-tokens: int           # The maximum number of tokens to generate, defaults to 100
    --no_interactive            # If true, will not ask to commit and will pipe the result
] {
    let git_status = (^git status | str trim)
    if $git_status =~ "^fatal" {
        error make {msg: $git_status}
    }
    let result = (^git diff --cached --no-color --raw -p)
    if $result == "" {
        error make {msg: "No changes"}
    }
    # let result = ($result | lines | each {|line| $"    ($line)"} | str join "\n")
    let input = $"Get the git diff of the staged changes:
```sh
git diff --cached --no-color --raw -p
```

Result of the comand:
```diff
($result)
```

Commit with a message that explains the staged changes:
```sh
git commit -m \""
    let max_tokens = ($max_tokens | default 2000)
    let openai_result = (api completion "gpt-3.5-turbo" --prompt $input --temperature 0.1 --top-p 1.0 --frequency-penalty 0 --presence-penalty 0 --max-tokens $max_tokens --stop '"')
    
    let openai_result = ($openai_result.choices.0.text | str trim)
    if not $no_interactive {
        print $"(ansi green)($openai_result)(ansi reset)"
        if (input "commit with this message ? (y/n) ") == "y" {
            git commit -m $openai_result
        }
    } else {
        $openai_result
    }
}


export def test [
    msg: string
] {
    
    api chat-completion "gpt-3.5-turbo" [{role:"user" content:"Hello!"}] --temperature 0 --top-p 1.0 --frequency-penalty 0.2 --presence-penalty 0 --max-tokens 64 --stop "\\n"
}