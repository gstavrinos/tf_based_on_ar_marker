#!/usr/bin/env julia
using RobotOS
using PyCall

@pyimport tf
@pyimport rospy
@rosimport tf2_msgs.msg: TFMessage

rostypegen()
using tf2_msgs.msg

function main()
    init_node("tf_based_on_ar_marker")
    parent_link = get_param("parent_link", "base_link")
    static_marker_link = get_param("static_marker_link", "ar_marker_link")
    ar_marker_link = get_param("ar_marker_link", "ar_marker_4")
    target_link = get_param("target_link", "head_camera")

    listener = tf.TransformListener()

    while ! is_shutdown()
        try
            t_ = listener[:getLatestCommonTime](ar_marker_link, target_link)
            trans, rot = listener[:lookupTransform](ar_marker_link, target_link, t_)
            t_ = listener[:getLatestCommonTime](parent_link, static_marker_link)
            trans2, rot2 = listener[:lookupTransform](static_marker_link, parent_link, t_)
            br = tf.TransformBroadcaster()
            br[:sendTransform]((trans[1]-trans2[1], trans[2]-trans2[2], trans[3]-trans2[3]),
                             tf.transformations[:quaternion_from_euler](0, 0, 0),
                             rospy.Time[:now](),
                             "dummy_link",
                             parent_link)
            println(trans)
            #roll = atan2(trans[3]-trans2[3],trans[2]-trans2[2])
            #pitch = atan2(trans[1]-trans2[1], trans[3]-trans2[3])
            #yaw = atan2(trans[2]-trans2[2],trans[1]-trans2[1])
         catch e
            println(e)
             continue
         end
    end
    spin()
end

main()