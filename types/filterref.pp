# an array for nwfilter references
type Libvirt::Filterref = Array[Optional[
    Struct[{
        filter     => String[1],
        parameters => Optional[
          Array[
            Hash[
              Pattern[/\A[A-Z]/],
              Variant[String[1],Integer],
            ]
          ]
        ]
    }]
]]
