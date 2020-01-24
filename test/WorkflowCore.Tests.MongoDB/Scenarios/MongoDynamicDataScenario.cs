using System;
using Microsoft.Extensions.DependencyInjection;
using WorkflowCore.IntegrationTests.Scenarios;
using Xunit;
using MongoDB.Bson.Serialization;
using  MongoDB.Bson.Serialization.Options;
using MongoDB.Bson.Serialization.Serializers;
using System.Collections.Generic;

namespace WorkflowCore.Tests.MongoDB.Scenarios
{
    [Collection("Mongo collection")]
    public class MongoDynamicDataScenario : DynamicDataIOScenario
    {
        protected override void ConfigureServices(IServiceCollection services)
        {
           services.AddWorkflow(x => x.UseMongoDB(MongoDockerSetup.ConnectionString, "integration-tests"));
        }
    }
}
