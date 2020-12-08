# config/.credo.exs
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: []
      },
      checks: [
        {Credo.Check.Consistency.TabsOrSpaces},

        {Credo.Check.Readability.MaxLineLength, [max_length: 120]},

        #
        # Design Checks
        #
        {Credo.Check.Design.AliasUsage,
         [priority: :low, if_nested_deeper_than: 2, if_called_more_often_than: 0]},
        {Credo.Check.Design.TagTODO, [exit_status: 0]},
        {Credo.Check.Design.TagFIXME, [exit_status: 0]},

        #
        # Warnings
        #
        {Credo.Check.Warning.ApplicationConfigInModuleAttribute, false}
      ]
    }
  ]
}

