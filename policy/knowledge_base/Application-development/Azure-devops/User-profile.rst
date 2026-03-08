User profile
=============

It's possible to change the name of your user profile in **Azure DevOps** when you disable **Microsoft Entra Profile information** in the *Preview Features*.

Context
--------------------

Sometimes pipelines fail when users in **Microsoft Entra** groups have invalid characters in their display name. This leads to error messages such as:

```
TF10158: The user or group name <<USER DISPLAY NAME HERE>> contains unsupported characters, is empty, or too long.
```

By changing your user profile name in Azure DevOps, you can prevent such issues.

Steps
------
1. Go to **Preview Features** in Azure DevOps.
2. Disable **Microsoft Entra Profile information**.
3. Update your user profile name to a valid value.

Best Practices for Profile Names
---------------------------------
.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Restriction type
     - Restriction
   * - Username length
     - Must not contain more than 256 unicode characters.
   * - Uniqueness
     - Must not match any other user account in the organization or project collection.
   * - Reserved group names
     - Must not include a namespace.
   * - Special characters
     - Must not include the following printable characters: ``< > , " / \ [ ] : + = ; ? * |``.
       Must not include nonprintable characters in the ASCII value range of 1-31.
       Must not end in a period . or a dollar sign $.
       Must not include the following unicode categories: LineSeparator, ParagraphSeparator, Control, Format, OtherNotAssigned.

For more details, see:  `Microsoft documentation <https://learn.microsoft.com/en-us/azure/devops/organizations/settings/naming-restrictions?view=azure-devops&tabs=git>`__.

Tip
----

Use allowed characters and make sure the name isn't too long to avoid pipeline errors.
