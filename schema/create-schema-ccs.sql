
use cloud;

CREATE TABLE IF NOT EXISTS `cloud`.`sb_ccs_container_cluster` (
    `id` bigint unsigned NOT NULL auto_increment COMMENT 'id',
    `uuid` varchar(40),
    `name` varchar(255) NOT NULL,
    `description` varchar(4096) COMMENT 'display text for this container cluster',
    `zone_id` bigint unsigned NOT NULL COMMENT 'zone id',
    `service_offering_id` bigint unsigned COMMENT 'service offering id for the cluster VM',
    `template_id` bigint unsigned COMMENT 'vm_template.id',
    `network_id` bigint unsigned COMMENT 'network this public ip address is associated with',
    `node_count` bigint NOT NULL default '0',
    `account_id` bigint unsigned NOT NULL COMMENT 'owner of this cluster',
    `domain_id` bigint unsigned NOT NULL COMMENT 'owner of this cluster',
    `state` char(32) NOT NULL COMMENT 'current state of this cluster',
    `key_pair` varchar(40),
    `cores` bigint unsigned NOT NULL COMMENT 'number of cores',
    `memory` bigint unsigned NOT NULL COMMENT 'total memory',
    `endpoint` varchar(255) COMMENT 'url endpoint of the container cluster manager api access',
    `console_endpoint` varchar(255) COMMENT 'url for the container cluster manager dashbaord',

    CONSTRAINT `fk_cluster__zone_id` FOREIGN KEY `fk_cluster__zone_id` (`zone_id`) REFERENCES `data_center` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_cluster__service_offering_id` FOREIGN KEY `fk_cluster__service_offering_id` (`service_offering_id`) REFERENCES `service_offering`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_cluster__template_id` FOREIGN KEY `fk_cluster__template_id`(`template_id`) REFERENCES `vm_template`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_cluster__network_id` FOREIGN KEY `fk_cluster__network_id`(`network_id`) REFERENCES `networks`(`id`) ON DELETE CASCADE,

    PRIMARY KEY(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cloud`.`sb_ccs_container_cluster_vm_map` (
    `id` bigint unsigned NOT NULL auto_increment COMMENT 'id',
    `cluster_id` bigint unsigned NOT NULL COMMENT 'cluster id',
    `vm_id` bigint unsigned NOT NULL COMMENT 'vm id',

    PRIMARY KEY(`id`),
    CONSTRAINT `container_cluster_vm_map_cluster__id` FOREIGN KEY `container_cluster_vm_map_cluster__id`(`cluster_id`) REFERENCES `sb_ccs_container_cluster`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cloud`.`sb_ccs_container_cluster_details` (
    `id` bigint unsigned NOT NULL auto_increment COMMENT 'id',
    `cluster_id` bigint unsigned NOT NULL COMMENT 'cluster id',
    `username` varchar(255) NOT NULL,
    `password` varchar(255) NOT NULL,

    PRIMARY KEY(`id`),
    CONSTRAINT `container_cluster_details_cluster__id` FOREIGN KEY `container_cluster_details_cluster__id`(`cluster_id`) REFERENCES `sb_ccs_container_cluster`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Advanced', 'DEFAULT', 'management-server',
'cloud.container.cluster.template.name', "ShapeBlue-CCS-Template", 'template name', '-1', NULL, NULL, 0);

INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Advanced', 'DEFAULT', 'management-server',
'cloud.container.cluster.master.cloudconfig', '/etc/cloudstack/management/k8s-master.yml' , 'file location path of the cloud config used for creating container cluster master node', '/etc/cloudstack/management/k8s-master.yml', NULL , NULL, 0);

INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Advanced', 'DEFAULT', 'management-server',
'cloud.container.cluster.node.cloudconfig', '/etc/cloudstack/management/k8s-node.yml', 'file location path of the cloud config used for creating container cluster node', '/etc/cloudstack/management/k8s-node.yml', NULL , NULL, 0);

INSERT IGNORE INTO `cloud`.`network_offerings` (name, uuid, unique_name, display_text, nw_rate, mc_rate, traffic_type, tags, system_only, specify_vlan, service_offering_id, conserve_mode, created,availability, dedicated_lb_service, shared_source_nat_service, sort_key, redundant_router_service, state, guest_type, elastic_ip_service, eip_associate_public_ip, elastic_lb_service, specify_ip_ranges, inline,is_persistent,internal_lb, public_lb, egress_default_policy, concurrent_connections, keep_alive_enabled, supports_streched_l2, `default`, removed) VALUES ('DefaultNetworkOfferingforContainerService', UUID(), 'DefaultNetworkOfferingforContainerService', 'Network Offering used for CloudStack container service', NULL,NULL,'Guest',NULL,0,0,NULL,1,now(),'Required',1,0,0,0,'Enabled','Isolated',0,1,0,0,0,0,0,1,1,NULL,0,0,0,NULL);

UPDATE `cloud`.`network_offerings` SET removed=NULL WHERE unique_name='DefaultNetworkOfferingforContainerService';

SET @ccsntwk = (select id from network_offerings where name='DefaultNetworkOfferingforContainerService' and removed IS NULL);
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'Dhcp','VirtualRouter',now());
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'Dns','VirtualRouter',now());
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'Firewall','VirtualRouter',now());
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'Gateway','VirtualRouter',now());
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'Lb','VirtualRouter',now());
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'PortForwarding','VirtualRouter',now());
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'SourceNat','VirtualRouter',now());
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'StaticNat','VirtualRouter',now());
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'UserData','VirtualRouter',now());
INSERT IGNORE INTO ntwk_offering_service_map (network_offering_id, service, provider, created) VALUES (@ccsntwk, 'Vpn','VirtualRouter',now());

INSERT IGNORE INTO `cloud`.`configuration` VALUES ('Advanced', 'DEFAULT', 'management-server',
'cloud.container.cluster.network.offering', 'DefaultNetworkOfferingforContainerService' , 'Network Offering used for CloudStack container service', 'DefaultNetworkOfferingforContainerService', NULL , NULL, 0);

CREATE TABLE IF NOT EXISTS `cloud`.`sb_ccs_version` (
     `id` bigint unsigned NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'id',
     `version` char(40) NOT NULL UNIQUE COMMENT 'version',
     `updated` datetime NOT NULL COMMENT 'Date this version table was updated',
     `step` char(32) NOT NULL COMMENT 'Step in the upgrade to this version',
     PRIMARY KEY (`id`),
     INDEX `i_version__version`(`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `cloud`.`sb_ccs_version` (version, updated, step) VALUES ('1.0', now(), 'Complete');
