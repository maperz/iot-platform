using Shared;

namespace Hub.Data.Entities
{
    public static class Mapping
    {
        public static DeviceState StateFromEntity(StateEntity entity)
        {
            return new ()
            {
                DeviceId = entity.DeviceId,
                Connected = false,
                LastUpdate = entity.LastUpdate,
                State = entity.State,
                Info = entity.Name != null
                    ? new DeviceInfo()
                    {
                        Name = entity.Name,
                        Type = entity.Type,
                        Version = entity.Version
                    }
                    : null
            };
        }
        
        public static StateEntity StateToEntity(DeviceState state)
        {
            return new ()
            {
                DeviceId = state.DeviceId,
                LastUpdate = state.LastUpdate,
                State = state.State,
                Name = state.Info?.Name,
                Type = state.Info?.Type,
                Version = state.Info?.Version
            };
        }
    }
}