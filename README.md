# confluence-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['confluence']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### confluence::default

Include `confluence` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[confluence::default]"
  ]
}
```

## License and Authors

Author:: Crossroads Foundation (<itdept@crossroads.org.hk>)
