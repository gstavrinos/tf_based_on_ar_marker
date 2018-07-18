#!/usr/bin/env julia
using RobotOS
using PyCall

@pyimport tf
@pyimport rospy
@rosimport geometry_msgs.msg: QuaternionStamped

rostypegen()
using geometry_msgs.msg

function main()
    init_node("tf_based_on_ar_marker")
    parent_link = get_param("parent_link", "base_link")
    static_marker_link = get_param("static_marker_link", "ar_marker_link")
    ar_marker_link = get_param("ar_marker_link", "ar_marker_4")
    target_link = get_param("target_link", "head_camera")
    dummy_target_link = rospy.get_param("dummy_target_link", "dummy_link")

    listener = tf.TransformListener()

    while ! is_shutdown()
        try
            t_ = listener[:getLatestCommonTime](ar_marker_link, target_link)
            trans, rot = listener[:lookupTransform](ar_marker_link, target_link, t_)
            t_ = listener[:getLatestCommonTime](parent_link, static_marker_link)
            trans2, rot2 = listener[:lookupTransform](static_marker_link, parent_link, t_)
            br = tf.TransformBroadcaster()
            #roll = atan2(trans2[3], trans2[1])
            #pitch = atan2(trans2[2] * cos(roll), trans2[1])
            #yaw = atan2(cos(roll), sin(roll) * sin(pitch))
            yaw = atan2(trans2[1], trans2[3])
            pitch = 0 #atan2(-trans2[2] * cos(yaw), -trans2[3])
            roll = 0 #atan2(cos(yaw), sin(yaw) * sin(pitch))


            #roll = atan(trans2[2], trans2[3])
            #pitch = atan(-trans2[3], -trans2[2])
            #pitch = atan2(trans2[1] * cos(roll), trans2[3])
            #roll = atan2(-trans2[1] * cos(pitch), -trans2[2])
            #yaw = atan2(cos(roll), sin(roll) * sin(pitch))
            #yaw = atan2(cos(pitch), sin(pitch) * sin(roll))
            x0 = rot[1]
            x1 = rot2[1]
            y0 = rot[2]
            y1 = rot2[2]
            z0 = rot[3]
            z1 = rot2[3]
            w0 = rot[4]
            w1 = rot2[4]
            r1 = tf.transformations[:euler_from_quaternion](rot)
            r2 = tf.transformations[:euler_from_quaternion](rot2)
            x = -trans2[1] #(trans[1]-trans2[1])*cos(rot[1]) + (trans[2]-trans2[2])*sin(rot[2]) + (trans[3]-trans2[3])*tan(rot[3])
            y = -trans2[2] #(trans[2]-trans2[2])*cos(rot[2]) + (trans[1]-trans2[1])*sin(rot[1]) + (trans[3]-trans2[3])*tan(rot[3])
            z = -trans2[3] #(trans[3]-trans2[3])*cos(rot[3]) + (trans[2]-trans2[2])*sin(rot[2]) + (trans[1]-trans2[1])*tan(rot[1])
            # q_ = QuaternionStamped()
            # q_.header.stamp = t_
            # q_.header.frame_id = ar_marker_link
            # q_.quaternion.x = rot2[1]
            # q_.quaternion.y = rot2[2]
            # q_.quaternion.z = rot2[3]
            # q_.quaternion.w = rot2[4]
            # q = listener[:transformQuaternion](static_marker_link, q_)
            # println(q)
            br[:sendTransform]((x, y, z),
                             (0, 0, 0, 1),
                             rospy.Time[:now](),
                             dummy_target_link,
                             parent_link)
            # r1 = tf.transformations[:euler_from_quaternion](rot)
            # r2 = tf.transformations[:euler_from_quaternion](rot2)
            # roll = 0#r1[1]*r2[1]
            # pitch = 0#r1[2]*r2[2]
            # yaw = atan2(trans[1] * (trans[1]-trans2[1])*sin(rot[1]), )
            # br[:sendTransform](((trans[1]-trans2[1])*sin(rot[1]), (trans[2]-trans2[2])*cos(rot[2]), (trans[3]-trans2[3])*tan(rot[3])),
            #                  tf.transformations[:quaternion_from_euler](roll, pitch, yaw),
            #                  rospy.Time[:now](),
            #                  dummy_target_link,
            #                  parent_link)
            #roll = atan2(trans[3]-trans2[3],trans[2]-trans2[2])
            #pitch = atan2(trans[1]-trans2[1], trans[3]-trans2[3])
            #yaw = atan2(trans[2]-trans2[2],trans[1]-trans2[1])
            println(trans2)
         catch e
            println(e)
            continue
         end
    end
    spin()
end

main()