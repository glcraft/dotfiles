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
# Lists the currently available models, and provides basic information about each one such as the owner and availability
# 
# If the model is set, It retrieves a model instance, providing basic information about the model such as the owner and permissioning.
export def models [
    --model: string    # The model to retrieve
] {
    let suffix = (if $model == null or $model == "" {
        ""
    } else {
        $"/($model)"
    })
    fetch $"https://api.openai.com/v1/models($suffix)" -H ["Authorization" $"Bearer (get-api)"]
}
# Helper function to add a parameter to a record if it's not null.
def add_param [name: string, value: any] {
    merge (if $value != null {
        { $name: $value }
    } else {
        {}
    })
}
# Raw completion API call.
# All parameters are optional, except for the model.
# See https://beta.openai.com/docs/api-reference/completions/create
export def completion [
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
    let result = (post "https://api.openai.com/v1/completions" -H ["Authorization" $"Bearer (get-api)"] -t 'application/json' $params)
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
# (Work in progress) Continues a previous completion.
export def go-on [
    --model: string                 # ID of the model to use.
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
    if not "openai" in $env {
        error make {msg: "No previous completion"}
    }
    let url = $env.openai.previous.url
    let params = ($env.openai.previous.parameters
        | add_param "model" $model
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

    let result = (post "https://api.openai.com/v1/completions" -H ["Authorization" $"Bearer (get-api)"] -t 'application/json' $params)
    # let params = ($params | merge {prompt: $"($params.prompt)($result.choices.0.text)"})
    # export-env {
    #     let-env openai = {
    #         previous: {
    #             parameters: $params
    #             url: $url
    #         }
    #     }
    # }
    $result
}
# Ask for a command to run. Will return one line command.
export def command [
    input?: string      # The command to run. If not provided, will use the input from the pipeline
    --shell: string     # The shell to use, defaults to $env.SHELL
    --max-tokens: int   # The maximum number of tokens to generate, defaults to 64
    --no-interactive    # If true, will not ask to execute and will pipe the result 
] {
    let input = ($in | default $input)
    if $input == null {
        error make {msg: "input is required"}
    }
    let shell = ($shell | default $env.SHELL)
    let max_tokens = ($max_tokens | default 64)
    let prompt = $"#!($shell)
# ($input), in one line: 
$ "
    let result = (completion "code-davinci-002" --prompt $prompt --temperature 0 --top-p 1.0 --frequency-penalty 0.2 --presence-penalty 0 --max-tokens $max_tokens --stop "\n"  )
    let result = $result.choices.0.text
    let result = (if $result =~ '^\s*#\s*' {
        ($result | parse -r '^\s*#\s*(?<command>.+)$').0.command | str trim
    } else {
        $result | str trim
    })
    if not $no_interactive {
        print $"(ansi green)($result)(ansi reset)"
        if (input "execute ? (y/n) ") == "y" {
            nu -c $"($result)"
        }
    } else {
        $result
    }
}
# Ask any question to the OpenAI model.
export def ask [
    input?: string                          # The question to ask. If not provided, will use the input from the pipeline
    --model: string = "text-davinci-003"    # The model to use, defaults to text-davinci-003
    --max-tokens: int                       # The maximum number of tokens to generate, defaults to 150
] {
    let input = ($in | default $input)
    if $input == null {
        error make {msg: "input is required"}
    }
    let max_tokens = ($max_tokens | default 150)
    let result = (completion $model --prompt $"($input)\n" --temperature 0.7 --top-p 1.0 --frequency-penalty 0 --presence-penalty 0 --max-tokens $max_tokens )
    $result.choices.0.text | str trim
}
