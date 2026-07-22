namespace WhiskyTools.Models;

public class WhiskyPresetSettings
{
    public List<double> VolumePresets { get; set; } = new();
    public List<double> TargetAbvPresets { get; set; } = new();
}
