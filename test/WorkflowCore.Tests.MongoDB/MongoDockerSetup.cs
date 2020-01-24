using Docker.DotNet;
using Docker.DotNet.Models;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using Docker.Testify;
using MongoDB.Driver;
using Xunit;

namespace WorkflowCore.Tests.MongoDB
{    
    public class MongoDockerSetup : DockerSetup
    {
        public static string ConnectionString { get; set; }

        public override string ImageName => "mongo";
        public override int InternalPort => 27017;

        public override void PublishConnectionInfo()
        {
            ConnectionString = "mongodb://admin:rise-x-@127.0.0.1:27017/?authSource=admin"; //$"mongodb://localhost:{ExternalPort}";
        }

        public override bool TestReady()
        {
            try
            {
                var client = new MongoClient(ConnectionString);
                client.ListDatabases();
                return true;
            }
            catch
            {
                return false;
            }

        }
    }

    [CollectionDefinition("Mongo collection")]
    public class MongoCollection : ICollectionFixture<MongoDockerSetup>
    {        
    }

}
