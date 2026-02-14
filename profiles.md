# Nix Store Size

Large `/nix/store` size is normal.

Reasons:

* Multiple system generations
* Cached toolchains
* Multiple nixpkgs revisions

To clean old generations:

```bash
sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system
sudo nix-collect-garbage -d
```

**Important:**
*Toolchains are stored ONCE globally.*
*Multiple projects do NOT duplicate them.*