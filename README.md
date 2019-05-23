# `opentsdb_encoderl`
[OpenTSDB telnet]() encoder in Erlang.  


## Build
```sh
~ $ git clone --depth 1 git/address/of/opentsdb_encoderl && cd opentsdb_encoderl
...
~/opentsdb_encoderl $ make
```

## Usage
```sh
~/opentsdb_encoderl $ make shell
Erlang/OTP 21 [erts-10.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:256] [hipe]
Eshell V10.1  (abort with ^G)
```
```erlang
%  Yields iolist:
1> opentsdb_encoderl:encode({measurement, 100, [{node, node()}]}).  
["put ","measurement"," ","1558635545"," ","100",
 [" ","node","=","opentsdb_encoderl@localhost"],
 "\n"]

%  Yields string:
2> opentsdb_encoderl:encode({<<"measurement">>, 100, #{"node" => node()}}, #{return_type => string}).
"put measurement 1558635583 100 node=opentsdb_encoderl@localhost\n"

%  Encodes keys and yeilds binary:
3> opentsdb_encoderl:encode({[<<"measurement">>, <<"key1">>, key2, "key3"], 100, #{"node" => node(), ip => "127.0.0.1"}}, #{return_type => binary}).
<<"put measurement.key1.key2.key3 1558635634 100 ip=127.0.0.1 node=opentsdb_encoderl@localhost\n">>

%            Encodes lines:
4> io:format(opentsdb_encoderl:encode([{measurement, X, [{tag, tag_value}], os:timestamp()} || X <- lists:seq(1, 100, 10)])).                       
put measurement 1558635741 1 tag=tag_value
put measurement 1558635741 11 tag=tag_value
put measurement 1558635741 21 tag=tag_value
put measurement 1558635741 31 tag=tag_value
put measurement 1558635741 41 tag=tag_value
put measurement 1558635741 51 tag=tag_value
put measurement 1558635741 61 tag=tag_value
put measurement 1558635741 71 tag=tag_value
put measurement 1558635741 81 tag=tag_value
put measurement 1558635741 91 tag=tag_value
ok

%  Also you can use maps (But timestamp is not allowed):
5> opentsdb_encoderl:encode(#{<<"measurement1">> => {10, #{k => v}}, measurement2 => {20, #{k2 => v2}}}, #{return_type => binary}).
<<"put measurement2 1558635826 20 k2=v2\nput measurement1 1558635826 10 k=v\n">>
```


#### Author
`pouriya.jahanbakhsh@gmail.com`
